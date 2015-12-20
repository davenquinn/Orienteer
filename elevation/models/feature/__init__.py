from geoalchemy2.types import Geometry
from geoalchemy2.shape import from_shape, to_shape
from shapely.geometry import mapping, shape

import numpy as N
from sqlalchemy.dialects.postgresql import array, ARRAY
from sqlalchemy.ext.associationproxy import association_proxy
from sqlalchemy.sql.expression import func, text

from ..base import db, BaseModel
from ..tag import Tag, feature_tag

from ...core.proj import srid

def wkb(shape):
    """Creates a WKB representation of the
    shape for inclusion in the database
    """
    return from_shape(shape, srid=srid.world)

class DatasetFeature(BaseModel):
    """A feature tied to a specific dataset. Has a pixel geometry
    and incorporates elevation data.
    """
    __tablename__ = "dataset_feature"
    __mapper_args__ = dict(
        polymorphic_identity = 'DatasetFeature',
        polymorphic_on = 'type')

    id = db.Column(db.Integer, primary_key=True)
    type = db.Column(db.String(64)) # Polymorphic discriminator column
    geometry = db.Column(Geometry(srid=srid.world))
    date_created = db.Column(db.DateTime,server_default=text("now()"), nullable=False)

    mapping = property(lambda self: self.__geo_interface__)
    shape = property(lambda self: to_shape(self.geometry))

    _tags = db.relationship("Tag",
        secondary=feature_tag,
        backref='features')
    tags = association_proxy('_tags','name')
    features = db.relationship("Dataset",
        backref="dataset")

    @property
    def __geo_interface__(self):
        return dict(
            type="Feature",
            geometry=mapping(to_shape(self.geometry)))

    dataset_id = db.Column(db.String(64), db.ForeignKey('dataset.id'))
    extracted = db.Column(ARRAY(db.Float, dimensions=2,zero_indexes=True))

    from .extract import extract

    def __init__(self,*args,**kwargs):
        self.extract()

    @property
    def array(self):
        return N.array(self.extracted)

    def map(self, size=(800,800), buffer=200):
        import mapnik as M
        from ..dataset.map import Map
        m = Map(self.dataset,*size)
        geom = self.session.scalar(
            self.geometry.ST_Centroid()
                .ST_Transform(srid.mars_eqc)
                .ST_Buffer(buffer))
        bounds = to_shape(geom).bounds
        m.zoom_to_box(M.Envelope(*bounds))
        return m

    def calculate(self):
        pass
