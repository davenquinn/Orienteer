from geoalchemy2 import Geometry
from geoalchemy2.shape import from_shape, to_shape
from flask import current_app as app
from .base import db, BaseModel
from ..core.proj import srid
from json import loads
from subprocess import check_output
from sqlalchemy import Column, String, Text

class Dataset(BaseModel):
    __tablename__ = "dataset"
    id = Column(String(64), primary_key=True)
    instrument = Column(String(64))
    dem_path = Column(Text)

    footprint = Column(Geometry("POLYGON", srid=srid.world))

    @property
    def bounds(self):
        with rasterio.open(self.dem_path) as f:
            return f.bounds

    def compute_footprint(self):
        """
        Computes a rough footprint of the polygonal area of the
        dataset (excluding nodata values).
        """
        from shapely.geometry import asShape

        output = check_output([
            "rio","shapes","--mask",self.dem_path])
        data = loads(output.decode('utf-8'))

        # Takes the largest contiguous geometry
        accepted_geom = None
        area = 0
        for feature in data['features']:
            geom = asShape(feature['geometry'])
            if geom.area > area:
                area = geom.area
                accepted_geom = geom

        self.footprint = from_shape(accepted_geom, srid.world)
