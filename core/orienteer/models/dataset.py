from geoalchemy2 import Geometry
from geoalchemy2.shape import from_shape, to_shape
from shapely.geometry import asShape
from flask import current_app as app
from .base import db, BaseModel
from json import loads
from subprocess import check_output
from sqlalchemy import Column, String, Text
import rasterio
import rasterio.features
import rasterio.warp

from ..config import SRID, FOOTPRINT_SRID
from ..core.proj import Projection


class Dataset(BaseModel):
    __tablename__ = "dataset"
    id = Column(String(64), primary_key=True)
    instrument = Column(String(64))
    dem_path = Column(Text)

    footprint = Column(Geometry("POLYGON", srid=FOOTPRINT_SRID))

    @property
    def bounds(self):
        with rasterio.open(self.dem_path) as f:
            return f.bounds

    def compute_footprint(self):
        """
        Computes a rough footprint of the polygonal area of the
        dataset (excluding nodata values).
        """
        with rasterio.open(self.dem_path) as dem:

            mask = dem.dataset_mask()
            crs = db.session.query(Projection).get(FOOTPRINT_SRID).crs

            # Extract feature shapes and values from the array.
            # Takes the largest contiguous geometry
            accepted_geom = None
            area = 0
            for geom, val in rasterio.features.shapes(mask, transform=dem.transform):
                shape = asShape(geom)
                if shape.area > area:
                    area = shape.area
                    accepted_geom = geom

            # Transform shapes from the dataset's own coordinate
            # reference system to CRS84 (EPSG:4326).
            # TODO: This won't work right now.
            geom = rasterio.warp.transform_geom(
                dem.crs, crs, accepted_geom, precision=6
            )
            self.footprint = from_shape(asShape(geom), FOOTPRINT_SRID)
