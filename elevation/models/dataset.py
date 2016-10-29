from geoalchemy2 import Geometry
from geoalchemy2.shape import from_shape, to_shape
from flask import current_app as app
from .base import db, BaseModel
from ..core.proj import srid
from json import loads
from subprocess import check_output

class Dataset(BaseModel):
    __tablename__ = "dataset"
    id = db.Column(db.String(64), primary_key=True)
    instrument = db.Column(db.String(64))
    dem_path = db.Column(db.Text)

    footprint = db.Column(Geometry("POLYGON", srid=srid.world))

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

        geom = asShape(data['features'][0]['geometry'])
        self.footprint = from_shape(geom, srid.world)
