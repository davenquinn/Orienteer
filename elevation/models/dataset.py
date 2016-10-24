from geoalchemy2 import Geometry
from geoalchemy2.shape import from_shape, to_shape
from flask import current_app as app
from .base import db, BaseModel
from ..core.proj import Projection, srid, transformation

class Dataset(BaseModel):
    __tablename__ = "dataset"
    id = db.Column(db.String(64), primary_key=True)
    instrument = db.Column(db.String(64))
    dem_path = db.Column(db.Text)

    footprint = db.Column(Geometry("POLYGON", srid=srid.world))

    # Whether footprint should be recalculated or is
    # user-controlled (for dataset cropping)
    manage_footprint = db.Column(db.Boolean, default=True)

    @property
    def bounds(self):
        with rasterio.open(self.dem_path) as f:
            return f.bounds

    def compute_footprint(self, tolerance=100):
        """
        Computes a rough footprint of the polygonal area of the
        dataset (excluding nodata values).

        :param tolerance: tolerance (in meters)
        """
        import rasterio
        from shapely.geometry import asShape
        from shapely.ops import transform
        from rasterio.features import shapes

        if not self.manage_footprint:
            return

        with rasterio.open(self.dem_path) as dem:
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
            self.footprint = from_shape(geom, srid=srid.world)
