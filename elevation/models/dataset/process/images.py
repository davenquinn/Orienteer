from __future__ import print_function
import os
from click import echo,style, secho

from ....app.proj import Projection, srid
from ....util import run, quote

_mapping = {
    "Figure of Merit": "fom",
    "DEM": "dem",
    "Orthophoto": "ortho"
}

def convert_image(im_spec):
    """
    Converts images to proper projection and adds overviews
    as appropriate. Orthophotos are projected to transverse
    mercator to assist in quick tile generation.
    """
    secho(im_spec["type"], bold=True)

    infile = "socet_output/images/"+im_spec["name"]
    outfile = "images/{}.tif".format(_mapping[im_spec["type"]])
    if os.path.isfile(outfile):
        secho(" File already exists",color="magenta")
        return

    if im_spec["type"] == "DEM":
        # We keep the DEM projected the same way
        # (this might be changed in the future,
        # but for now it enables us to keep track
        # of imported data without doing a mass rollover
        cmd = ["gdal_translate"]
    else:
        # Datasets primarily for viewing are reprojected
        # to transverse mercator
        proj = Projection.query.get(srid.local).proj4
        cmd = [
            "gdalwarp",
            "-t_srs", quote(proj)]
    cmd += ["-of GTiff", "-co BIGTIFF=YES", quote(infile), quote(outfile)]
    run(*cmd)

    # Add overviews for different levels
    levels = [str(2**(i+1)) for i in range(12)]
    opts = ["--config COMPRESS_OVERVIEW JPEG",
            quote(outfile)] + levels
    run("gdaladdo", *opts)
