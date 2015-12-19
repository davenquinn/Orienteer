import click
import numpy as N

from os import path
from affine import Affine
from flask import current_app
from nimble import compute_transform, align_image
from nimble.sql import transform_geometry, endpoints

from ..models import Dataset, DatasetFeature, DatasetOffset
from ..util.cli import run
from ..database import db
from ..core.proj import srid

def tiepoints(dataset):
    # Get tiepoints
    o = DatasetOffset
    criteria = o.from_dataset == dataset.id
    return endpoints(o.geometry,
        db.session.query(o).filter(criteria))

@click.command()
@click.option('--footprints', is_flag=True, default=False)
def georeference(footprints=False):

    transforms = {}
    for d in Dataset.query.all():

        try:
            affine = compute_transform(tiepoints(d))
        except ValueError:
            # There aren't any points
            affine = Affine.identity()

        # Save transform for manipulation of features
        transforms[d.id] = affine

        # Image
        image = d.path("images","ortho.tif")
        fn = align_image(affine, image)

        # DEM
        dem = d.path('images','dem.tif')
        out = d.path('images','dem.aligned.vrt')
        fn = align_image(affine, dem, outfile=out)

        if footprints:
            d.compute_footprint()
        db.session.add(d)
        db.session.commit()

    # Create HiRISE mosaic
    hirise_images = (db.session.query(Dataset)
        .filter_by(instrument='HiRISE')
        .all())
    base = current_app.config.get("PROJECT_DIR")

    aligned_images = [d.path('images','ortho.aligned.vrt')
            for d in hirise_images]
    run("gdalbuildvrt","-overwrite",
        path.join(base,"hirise-ortho.aligned.vrt"),
        *aligned_images)

    aligned_dems = [d.path('images','dem.aligned.vrt')
            for d in hirise_images]
    run("gdalbuildvrt","-overwrite",
        path.join(base,"hirise-dem.aligned.vrt"),
        *aligned_dems)

    for feature in DatasetFeature.query.all():
        _ = transforms.get(feature.dataset.id, Affine.identity())
        if feature.original_geometry is None:
            # Maybe we want to back-calculate instead?
            continue
        feature.geometry = transform_geometry(_,
                feature.original_geometry,
                image_srid = srid.local)

        db.session.add(feature)
    db.session.commit()
