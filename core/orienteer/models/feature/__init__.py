from geoalchemy2.types import Geometry
from geoalchemy2.shape import from_shape, to_shape
from shapely.geometry import mapping, shape
from shapely.ops import transform
import numpy as N
from sqlalchemy.dialects.postgresql import ARRAY
from sqlalchemy.sql.expression import func, text
from sqlalchemy.orm import relationship
from sqlalchemy import (
    Column,
    String,
    Text,
    Integer,
    DateTime,
    ForeignKey,
    Boolean,
    Float,
)
import rasterio
import rasterio.env
from pg_projector import transformation

from ...config import SRID
from ..base import db, BaseModel
from ...database import db
from ...core.proj import Projection
from .extract import extract_area, extract_line, clean_coordinates, project_array


def wkb(shape):
    """Creates a WKB representation of the
    shape for inclusion in the database
    """
    return from_shape(shape, srid=SRID)


class Project(BaseModel):
    __tablename__ = "project"
    id = Column(Integer, primary_key=True)
    name = Column(Text, nullable=False)
    # We define the foreign key constraint in SQL because
    # we are having trouble doing this in the ORM code.
    srid = Column(Integer)


class FeatureClass(BaseModel):
    __tablename__ = "feature_class"
    id = Column(String, primary_key=True)
    type = Column(String)
    description = Column(Text)
    color = Column(Text)


class DatasetFeature(BaseModel):
    """A feature tied to a specific dataset. Has a pixel geometry
    and incorporates elevation data.
    """

    __tablename__ = "dataset_feature"

    id = Column(Integer, primary_key=True)
    type = Column(String(64))  # Polymorphic discriminator column
    geometry = Column(Geometry(srid=SRID))
    date_created = Column(DateTime, server_default=text("now()"), nullable=False)
    project = Column(Integer, ForeignKey(Project.id), nullable=False)

    mapping = property(lambda self: self.__geo_interface__)
    shape = property(lambda self: to_shape(self.geometry))
    dataset = relationship("Dataset", backref="features")

    @property
    def __geo_interface__(self):
        return dict(type="Feature", geometry=mapping(to_shape(self.geometry)))

    _class = Column("class", String, ForeignKey("feature_class.id"))
    dataset_id = Column(String(64), ForeignKey("dataset.id"))
    extracted = Column(ARRAY(Float, dimensions=2, zero_indexes=True))
    # Column to track whether the dataset_id
    # was set using a script or user-specified
    dataset_id_autoset = Column(
        Boolean, default=False, nullable=False, server_default="0"
    )

    def extract(self):
        source_crs = db.session.query(Projection).get(self.geometry.srid).crs
        demfile = self.dataset.dem_path

        dest_crs = (
            db.session.query(Projection)
            .join(Project, Projection.srid == Project.srid)
            .join(self.__class__)
            .first()
        )

        with rasterio.open(demfile) as dem:
            dem_crs = dem.crs.to_dict()
            # Transform the shape to the DEM's projection or the target projection if defined
            projection = transformation(source_crs, dem_crs)
            # Add some asserts here maybe since we don't do any cleaning

            geom_shape = to_shape(self.geometry)
            geom = transform(projection, geom_shape)

            if len(geom.coords) == 0:
                raise ValueError("Trying to transform an empty geometry")

            if geom.area == 0:
                coords = extract_line(geom, dem)
            else:
                coords = extract_area(geom, dem)

            # Transform coordinates back to transverse mercator
            if dest_crs is not None:
                coords = project_array(coords, dem_crs, dest_crs.crs)

        coords = clean_coordinates(coords, silent=True)
        assert len(coords) > 0

        print(coords)

        self.extracted = coords.tolist()

    def __init__(self, *args, **kwargs):
        self.extract()

    @property
    def array(self):
        return N.array(self.extracted)

    @property
    def length(self):
        return db.session.scalar(func.ST_Length(self.geometry))
