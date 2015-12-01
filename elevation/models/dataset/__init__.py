import os
import rasterio
from ..base import db, BaseModel

from sqlalchemy import func
from sqlalchemy.dialects.postgresql import ARRAY
from geoalchemy2 import Geometry
from geoalchemy2.shape import from_shape, to_shape

import numpy as N
from shapely.geometry import asShape
from shapely.ops import transform
from rasterio.features import shapes
from syrtis.core.proj import Projection, srid, transformation

class DatasetOffset(BaseModel):
    """
    A model to manage offsets in georeferenced image networks
    """
    __tablename__ = "dataset_offset"
    id = db.Column(db.Integer, primary_key=True)
    from_dataset = db.Column(
            db.String(64),
            db.ForeignKey('dataset.id',ondelete='CASCADE'),
            nullable=False)

    # If this column is defined, offsets will be additive
    # with any defined for the to_dataset, allowing for a
    # geodetic framework to be progressively assembled for
    # nested image references. If not defined, the image
    # will be shifted against the global frame.
    to_dataset = db.Column(
            db.String(64),
            db.ForeignKey('dataset.id',ondelete='CASCADE'),
            nullable=True)

    # Column to show movement between original georeference
    # (first endpoint of the line) to secondary georeference
    # (second endpoint). Assumes that a full affine translation
    # is unnecessary.
    geometry = db.Column(Geometry("LINESTRING", srid=srid.local))

class Dataset(BaseModel):
    __tablename__ = "dataset"
    id = db.Column(db.String(64), primary_key=True)
    instrument = db.Column(db.String(64))

    footprint = db.Column(Geometry("POLYGON", srid=srid.world))

    # Whether footprint should be recalculated or is
    # user-controlled (for dataset cropping)
    manage_footprint = db.Column(db.Boolean, default=True)

    # Foreign key constraints
    features = db.relationship("DatasetFeature", backref="dataset")
    attitudes = db.relationship("Attitude")

    from .process import import_data, build_contours, compute_residuals

    @property
    def basedir(self):
        from ..... import app
        BASEDIR = app.config.get("PROJECT_DIR")
        return os.path.join(BASEDIR,self.id)

    def path(self,*args):
        return os.path.join(self.basedir,*args)

    @property
    def bounds(self):
        with rasterio.open(self.path("images","dem.tif")) as f:
            return f.bounds

    def compute_footprint(self, tolerance=100):
        """
        Computes a rough footprint of the polygonal area of the
        dataset (excluding nodata values).

        :param tolerance: tolerance (in meters)
        """
        if not self.manage_footprint:
            return

        with rasterio.open(self.path("images","dem.tif")) as dem:
            mask = dem.read_masks(1)

            # Get polygons for shapes corresponding to
            # non-NaN area, in map coordinates
            polygons = list(shapes(mask, mask, 8, dem.affine))
            # Simplify using Douglas-Peucker algorithm
            geom = asShape(polygons[0][0])\
                .simplify(tolerance, preserve_topology=False)

            # Create transformation into Mars2000 (lat lng)
            mars = Projection.query.get(srid.world)
            proj = transformation(dem.crs,mars.crs)

            geom = transform(proj,geom)
            self.original_footprint = from_shape(geom, srid=srid.world)
