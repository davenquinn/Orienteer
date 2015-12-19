from __future__ import print_function

import numpy as N
import os
import rasterio
from sqlalchemy.exc import ProgrammingError
from click import echo, secho, style
from flask import current_app

from ....util.cli import working_directory, run, quote, execute_sql
from ...base import db
from ...feature.manage import create_features
from ....core.proj import Projection, srid
from ...attitude import Attitude
from .images import convert_image

from rasterio.warp import reproject, RESAMPLING

def build_downsampled(dataset):
    """
    Builds a downsampled copy of the DEM at 25%
    resolution and projected to transverse mercator.
    Always overwrites the previous image.
    """
    dem = quote(dataset.path("images","dem.aligned.vrt"))
    vrtA = quote(dataset.path("images","dem_downsampled.vrt"))

    outfile = dataset.path("images","dem_downsampled_tm.tif")

    run("gdal_translate -of VRT",
        "-outsize 25% 25%",
        dem, vrtA)

    proj = Projection.query.get(srid.local).proj4
    run("gdalwarp -of GTiff",
        "-overwrite",
        "-t_srs",
        quote(proj), vrtA, quote(outfile))

def build_contours(dataset,overwrite=False):
    """
    Build dataset contours as PostgreSQL table
    """
    downsampled = dataset.path("images","dem_downsampled_tm.tif")
    table = "contour.{}".format(dataset.id)

    if overwrite:
        secho("Dropping table...")
        execute_sql("DROP TABLE {} CASCADE;".format(table))
        run("rm -f", quote(downsampled))

    # Build downsampled DEM if we don't have it.
    if not os.path.isfile(downsampled):
        build_downsampled(dataset)

    i = 1
    if dataset.instrument == "CTX":
        i = 10

    cmd = [
        "gdal_contour",
        "-f PostgreSQL",
        "-i {} -a elevation".format(i),
        "-nln "+table,
        "-dsco DIM=2",
        "-dsco GEOMETRY_NAME=geometry",
        "-lco OVERWRITE=NO",
        quote(downsampled),
        "PG:dbname=syrtis"
    ]
    run(*cmd)

    q = """ALTER TABLE {schema}.{table}
            ALTER COLUMN wkb_geometry
            TYPE geometry(LINESTRING, {srid})
            USING ST_SetSRID(wkb_geometry,{srid});""".format(
            schema = "contour",
            table = dataset.id,
            srid = srid.local)
    execute_sql(q)

def compute_residuals(dataset, rebuild=False, show_stats=False):
    IMAGE_DIR = current_app.config.get("IMAGE_DIR")

    mola_dem = os.path.join(IMAGE_DIR,"MOLA","regional-128ppd.tif")

    dem = dataset.path("images","dem.tif")
    outfile = dataset.path("images","mola-residuals.tif")

    arr = None

    if rebuild:
        run("rm -f",outfile)

    if os.path.isfile(outfile):
        return

    echo("Computing residuals for image "+dataset.id)

    with rasterio.open(dem,"r") as dem,\
        rasterio.open(mola_dem,"r") as mola:

        band = mola.read(1)
        mola_prj = N.ma.zeros(dem.shape)

        reproject(
            band,
            mola_prj,
            src_transform=mola.affine,
            src_crs=mola.crs,
            dst_transform=dem.affine,
            dst_crs=dem.crs,
            dst_nodata=None,
            resampling=RESAMPLING.bilinear)

        arr = dem.read(1,masked=True)-mola_prj

        meta = dem.meta
        meta.update(compress="lzw")
        with rasterio.open(outfile,"w",**meta) as res:
            res.write_band(1,arr.astype(N.float32))

    params = [("Min",arr.min()),
              ("Max",arr.max()),
              ("Std",arr.std()),
              ("Avg",arr.mean())]

    for l,n in params:
        echo(l+": {0:.2f}".format(n))




def import_data(dataset, config, rebuild=False, extract=False):
    feature_mapping = [
        dict(name="BEDDING",type="bedding"),
        dict(name="Bedding",type="bedding"),
        dict(name="DIPSLOPE",type="bedding"),
        dict(name="Dipslope",type="bedding")]

    with working_directory(dataset.basedir):
        if rebuild:
            run("rm -rf images")
        run("mkdir -p images")

        for file in config["images"]:
            convert_image(file)

        if extract:
            for shapefile in feature_mapping:
                if shapefile["type"] == "bedding":
                    create_features(
                        Attitude,
                        dataset,
                        shapefile["name"])
                elif shapefile["type"] == "annotation":
                    create_features(
                        Annotation,
                        dataset,
                        shapefile["name"])
                else:
                    s = "Feature set of type {0} not yet supported"
                    print(s.format(shapefile["type"]))

        #compute_residuals(dataset, rebuild)
        if rebuild:
            build_contours(dataset,rebuild)
            echo("Computing footprint...")
            dataset.compute_footprint()
