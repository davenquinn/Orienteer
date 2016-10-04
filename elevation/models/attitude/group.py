import numpy as N
from sqlalchemy.ext.associationproxy import association_proxy
from attitude.coordinates import centered

from .interface import db, AttitudeInterface
from ..tag import attitude_group_tag

class AttitudeGroup(db.Model, AttitudeInterface):
    __tablename__ = 'attitude_group'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(128))
    desc = db.Column(db.Text)

    same_plane = db.Column(db.Boolean,
            nullable=False, default=False)

    measurements = db.relationship("Attitude",
            lazy='joined', backref="group")

    _tags = db.relationship("Tag",
        secondary=attitude_group_tag,
        backref='attitude_groups')
    tags = association_proxy('_tags','name')

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
            singularValues=self.covariance,
            axes=self.principal_axes,
            measurements=[m.id\
                for m in self.measurements])
