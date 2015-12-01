from __future__ import print_function, division

import numpy as N
import fiona
from fiona import crs
from osgeo import osr
import os
from click import echo

from shapely.geometry import mapping, shape
from shapely.ops import transform
from . import wkb
from ...database import db
from syrtis.core.proj import Projection, srid
from geoalchemy2.shape import from_shape, to_shape
from sqlalchemy.sql.expression import func

def planetocentric_transform(semimajor, semiminor):
    """Converts a planetographic latitude to planetocentric
        using a shapefile as a guide for the projection
    """
    if semiminor is None:
        flattening_factor = 1
    else:
        flattening_factor = (semiminor/semimajor)**2

    def transform_func(x,y,z=None):
        assert abs(y) <= 90
        lat = N.tan(N.radians(y))*flattening_factor
        y = N.degrees(N.arctan(lat))
        return (x,y)

    return lambda s: transform(transform_func, s)

def axis_lengths(shapefile, inverse_flattening=None):
    """
    Gets the length of the geoid's semimajor and semiminor
    axes from a shapefile's projection.
    """
    prj = os.path.splitext(shapefile)[0]+".prj"
    with open(prj,"r") as proj:
        spatial_ref = osr.SpatialReference()
        spatial_ref.ImportFromWkt(proj.read())
    semimajor = spatial_ref.GetSemiMajor()
    semiminor = spatial_ref.GetSemiMinor()
    if inverse_flattening:
        # We allow the user to specify their own value for inverse
        # flattening, because this is required for Earth-Mars CRS
        # translations
        semiminor = semimajor-semimajor/inverse_flattening
    return semimajor, semiminor

def create_features(cls, dataset, filename):
    """ Creates features from SocetSET-imported geometries.
    """
    crs = Projection.query.get(srid.world).crs
    inf = crs["a"]/(crs["a"]-crs["b"])

    shp = dataset.path("socet_output","features","{0}.shp".format(filename))
    if not os.path.exists(shp): return
    axes = axis_lengths(shp, inverse_flattening=inf)
    planetocentric = planetocentric_transform(*axes)

    with fiona.open(shp, "r") as infile:
        features = []
        for feature in infile:
            s = planetocentric(shape(feature["geometry"]))
            geom = wkb(s)
            equals = func.ST_Equals(
                    func.ST_SnapToGrid(cls.geometry,0.00001),
                    func.ST_SnapToGrid(geom,0.00001))
            instance = db.session.query(cls)\
                .filter(cls.dataset == dataset)\
                .filter(equals)\
                .first()
            if instance:
                echo("{0} already exists".format(cls.__name__))
                continue
            try:
                f = cls(
                    dataset=dataset,
                    geometry=geom)
                db.session.add(f)
                db.session.flush()
                if hasattr(f,"calculate"):
                    f.calculate()
            except AssertionError:
                continue
            features.append(f)

        db.session.commit()
