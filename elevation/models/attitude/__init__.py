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
    __mapper_args__ = dict(
        polymorphic_identity = 'Attitude')

    id = db.Column(
        db.Integer,
        db.ForeignKey('dataset_feature.id'),
        primary_key=True)

    location = db.Column(Geometry(
            "POINT", srid=srid.world))

    valid = db.Column(db.Boolean)
    group_id = db.Column(
        db.Integer,
        db.ForeignKey('attitude_group.id'))

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
