import numpy as N
from shapely.geometry import mapping
from sqlalchemy import func

from geoalchemy2.types import Geometry
from geoalchemy2.shape import from_shape, to_shape

from .group import AttitudeGroup
from .interface import db, AttitudeInterface
from ..feature import DatasetFeature, srid

class Attitude(DatasetFeature, AttitudeInterface):
    __tablename__ = 'attitude'

    id=db.Column(db.Integer,primary_key=True)
    feature_id = db.Column(
        db.Integer,
        db.ForeignKey('dataset_feature.id'))

    location = db.Column(Geometry("POINT", srid=srid.world))

    valid = db.Column(db.Boolean)
    member_of = db.Column(
        db.Integer,
        db.ForeignKey('attitude.id'))
    grouped = db.Column(db.Boolean)

    __mapper_args__ = dict(
        polymorphic_on=grouped,
        polymorphic_identity=False,
        with_polymorphic='*')

    __table_args__ = (
        # Check that we don't define group membership and feature
        # if isn't a group.
        CheckConstraint('NOT grouped OR (group_id IS NULL AND feature_id IS NULL)'),
    )


    def serialize(self):
        pca = self.pca()
        s = N.diagonal(pca.covariance_matrix)
        axes = pca.axes
        if N.isnan(axes).sum():
            axes = None
        else:
            axes = axes.tolist()

        return dict(
            type="Feature",
            id=self.id,
            tags=list(self.tags),
            geometry=mapping(to_shape(self.geometry)),
            properties=dict(
                r=self.correlation_coefficient,
                p=self.planarity,
                center=mapping(to_shape(self.location)),
                strike=self.strike,
                dip=self.dip,
                singularValues=s.tolist(),
                axes=axes))

    def calculate(self):
        self.location = from_shape(self.shape.centroid,
                srid=srid.world)
        AttitudeInterface.calculate(self)
