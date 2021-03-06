from geoalchemy2.types import Geometry
from geoalchemy2.shape import from_shape, to_shape
from shapely.geometry import mapping, shape

import numpy as N
from sqlalchemy.dialects.postgresql import array, ARRAY
from sqlalchemy.sql.expression import func, text
from sqlalchemy.orm import relationship
from sqlalchemy import (
    Column, String, Text, Integer,
    DateTime, ForeignKey, Boolean, Float)

from ...core import SRID
from ..base import db, BaseModel

def wkb(shape):
    """Creates a WKB representation of the
    shape for inclusion in the database
    """
    return from_shape(shape, srid=SRID)

class FeatureClass(BaseModel):
    __tablename__ = "feature_class"
    id = Column(String, primary_key=True)
    type = Column(String)

class DatasetFeature(BaseModel):
    """A feature tied to a specific dataset. Has a pixel geometry
    and incorporates elevation data.
    """
    __tablename__ = "dataset_feature"

    id = Column(Integer, primary_key=True)
    type = Column(String(64)) # Polymorphic discriminator column
    geometry = Column(Geometry(srid=SRID))
    date_created = Column(DateTime,server_default=text("now()"), nullable=False)

    mapping = property(lambda self: self.__geo_interface__)
    shape = property(lambda self: to_shape(self.geometry))
    dataset = relationship("Dataset",
        backref='features')

    @property
    def __geo_interface__(self):
        return dict(
            type="Feature",
            geometry=mapping(to_shape(self.geometry)))

    _class = Column("class", String, ForeignKey('feature_class.id'))
    dataset_id = Column(String(64), ForeignKey('dataset.id'))
    extracted = Column(ARRAY(Float, dimensions=2,zero_indexes=True))
    # Column to track whether the dataset_id
    # was set using a script or user-specified
    dataset_id_autoset = Column(Boolean, default=False, nullable=False,
                                server_default="0")

    from .extract import extract

    def __init__(self,*args,**kwargs):
        self.extract()

    @property
    def array(self):
        return N.array(self.extracted)

    @property
    def length(self):
        return db.session.scalar(
            func.ST_Length(self.geometry))

