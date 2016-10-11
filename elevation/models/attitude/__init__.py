import numpy as N
from shapely.geometry import mapping
from sqlalchemy import func, CheckConstraint

from geoalchemy2.types import Geometry
from geoalchemy2.shape import from_shape, to_shape

from .interface import db, AttitudeInterface
from ..feature import DatasetFeature, srid

class Attitude(db.Model, AttitudeInterface):
    __tablename__ = 'attitude_new'
    __mapper_args__ = dict(
        polymorphic_on='type',
        polymorphic_identity='single')

    id=db.Column(db.Integer, primary_key=True)
    type = db.Column(db.String)
    feature_id = db.Column(
        db.Integer,
        db.ForeignKey('dataset_feature.id'))

    location = db.Column(Geometry("POINT", srid=srid.world))

    valid = db.Column(db.Boolean)
    member_of = db.Column(
        db.Integer,
        db.ForeignKey('attitude_new.id'))

    # group = db.relationship("AttitudeGroup",
            # back_populates="measurements",
            # remote_side="AttitudeGroup.id")

    __table_args__ = (
        # Check that we don't define group membership and feature
        # if isn't a group.
        CheckConstraint('NOT grouped OR (group_id IS NULL AND feature_id IS NULL)'),
    )

    def serialize(self):
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
                n_samples=self.n_samples,
                covariance=self.covariance,
                axes=self.principal_axes))

    def calculate(self):
        self.location = from_shape(self.shape.centroid,
                srid=srid.world)
        AttitudeInterface.calculate(self)

    def __str__(self):
        return "Attitude {}".format(self.id)

class AttitudeGroup(Attitude):
    __mapper_args__ = dict(
        polymorphic_identity='grouped')

    same_plane = db.Column(db.Boolean,
            nullable=False, default=False)

    # measurements = db.relationship(Attitude,
            # back_populates="group",
            # remote_side=Attitude.id)

    def __init__(self, features, **kwargs):
        db.Model.__init__(self,**kwargs)
        self.measurements = features
        self.calculate()

    def __str__(self):
        return "Group {}".format(self.id)

    @property
    def centered_array(self):
        if self.same_plane:
            a = "array"
        else:
            a = "centered_array"
        arrays = [getattr(m,a)
            for m in self.measurements]

        if len(arrays) == 0:
            return N.array([])

        arr = N.concatenate(arrays)
        if self.same_plane:
            return centered(arr)
        else:
            return arr

    @property
    def array(self):
        return N.concatenate([m.array
            for m in self.measurements])

    def serialize(self):
        return dict(
            type="GroupedAttitude",
            id=self.id,
            strike=self.strike,
            dip=self.dip,
            tags=list(self.tags),
            same_plane=self.same_plane,
            r=self.correlation_coefficient,
            p=self.planarity,
            n_samples=self.n_samples,
            covariance=self.covariance,
            axes=self.principal_axes,
            measurements=[m.id\
                for m in self.measurements])
