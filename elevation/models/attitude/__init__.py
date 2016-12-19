from __future__ import division

import numpy as N
from shapely.geometry import mapping
from sqlalchemy.orm import column_property, object_session
from sqlalchemy import func, select, cast, CheckConstraint
from sqlalchemy.ext.associationproxy import association_proxy
import logging as log

from geoalchemy2.types import Geometry
from geoalchemy2.shape import from_shape, to_shape

from attitude.orientation import Orientation
from attitude.coordinates import centered
from attitude.error.axes import sampling_axes, noise_axes, angular_errors
from sqlalchemy.dialects.postgresql import array, ARRAY
from sqlalchemy.ext.associationproxy import association_proxy
from sqlalchemy.ext.hybrid import hybrid_property
from sqlalchemy.orm import relationship
from sqlalchemy import (
    Column, String, Text,
    Integer, DateTime,
    ForeignKey, Boolean, Float)

from .tag import Tag, attitude_tag
from ..feature import DatasetFeature, srid
from ...database import db
from ..base import BaseModel

class Attitude(BaseModel):
    __tablename__ = 'attitude'
    __mapper_args__ = dict(
        polymorphic_on='type',
        polymorphic_identity='single')

    id=Column(Integer, primary_key=True)
    type = Column(String)
    feature_id = Column(
        Integer,
        ForeignKey('dataset_feature.id'))

    feature = relationship(DatasetFeature)

    strike = Column(Float)
    dip = Column(Float)
    correlation_coefficient = Column(Float)

    principal_axes = Column(ARRAY(Float,
        dimensions=2,zero_indexes=True))
    singular_values = Column(ARRAY(Float,zero_indexes=True))
    covariance = Column(ARRAY(Float,zero_indexes=True))
    n_samples = Column(Integer)
    max_angular_error = Column(Float)
    min_angular_error = Column(Float)

    geometry = association_proxy('feature','geometry')
    location = Column(Geometry("POINT", srid=srid.world))

    valid = Column(Boolean)
    member_of = Column(
        Integer,
        ForeignKey('attitude.id'))

    group = relationship("AttitudeGroup",
            back_populates="measurements",
            remote_side=id)

    _tags = relationship("Tag",
        secondary=attitude_tag,
        backref='features')
    tags = association_proxy('_tags','name')

    __table_args__ = (
        # Check that we don't define group membership and feature
        # if isn't a group.
        CheckConstraint("feature_id IS NOT NULL = (type = 'single')"),
        # Groups should not be members of other groups
        CheckConstraint("type IN ('group','collection') = (member_of IS NULL AND feature_id IS NULL)"))

    @property
    def aligned_array(self):
        """
        Array aligned with the principal components
        of the orientation measurement.
        """
        return N.array(self.feature.axis_aligned)

    def error_ellipse(self):
        from .plot import error_ellipse
        return error_ellipse(self)

    def plot_aligned(self):
        from attitude.plot import plot_aligned
        return plot_aligned(self.pca())

    @property
    def array(self):
        return self.feature.array

    @property
    def centered_array(self):
        return centered(self.array)

    def regress(self):
        return self.pca

    def pca(self):
        """
        Initialize a principal components
        analysis against the attitude.
        """
        try:
            return self.__pca
        except AttributeError:
            a = self.centered_array
            ax = N.array(self.principal_axes)*N.array(self.singular_values)
            self.__pca = Orientation(a, axes=ax)
            return self.__pca

    def __repr__(self):
        def val(obj, s):
            try:
                return s.format(obj)
            except ValueError:
                return "unmeasured"
            except TypeError:
                return "unmeasured"
        s = "{cls} {id}: strike {s}, dip {d}"\
            .format(
                cls = self.__class__.__name__,
                id = self.id,
                s = val(self.strike, "{0:.1f}"),
                d = val(self.dip, "{0:.1f}"))
        return s

    def serialize(self):
        return dict(
            type="Feature",
            id=self.id,
            tags=list(self.tags),
            geometry=mapping(to_shape(self.feature.geometry)),
            properties=dict(
                r=self.correlation_coefficient,
                center=mapping(to_shape(self.location)),
                strike=self.strike,
                dip=self.dip,
                n_samples=self.n_samples,
                covariance=self.covariance,
                axes=self.principal_axes))

    def calculate(self):
        self.location = func.ST_Centroid(self.geometry)

        try:
            pca = Orientation(self.centered_array)
        except IndexError:
            # If there aren't enough coordinates
            return
        self.principal_axes = pca.axes.tolist()
        self.singular_values = pca.singular_values.tolist()

        # Really this is hyperbolic axis lengths
        # should change API to reflect this distinction
        self.covariance = sampling_axes(pca).tolist()
        self.n_samples = pca.n
        self.strike, self.dip = pca.strike_dip()
        if self.dip == 90:
            self.valid = False

        a = angular_errors(self.covariance)
        self.min_angular_error = 2*N.degrees(a[0])
        self.max_angular_error = 2*N.degrees(a[1])

        # Analogous to correlation coefficient for PCA
        # but not exactly the same
        self.correlation_coefficient = pca.explained_variance

    def extract(self, *args,**kwargs):
        self.feature.extract(*args,**kwargs)

    def __str__(self):
        return "Attitude {}".format(self.id)

class AttitudeGroup(Attitude):
    __mapper_args__ = dict(
        polymorphic_identity='group')

    same_plane = Column(Boolean,
            nullable=False, default=False)

    measurements = relationship(Attitude)

    def __init__(self, attitudes, **kwargs):
        Attitude.__init__(self,**kwargs)
        self.measurements = attitudes
        self.calculate()

    def __str__(self):
        return "Group {}".format(self.id)

    # Add a property for geometry that creates a union
    # of all component data
    def __build_geometry(self):
        """
        Un-executed query to find geometry from component
        parts
        """
        __ = func.ST_Union(DatasetFeature.geometry)
        return (select([func.ST_SetSrid(__,srid.world)])
            .select_from(DatasetFeature.__table__.join(Attitude))
            .where(Attitude.member_of==self.id)
            .group_by(Attitude.member_of))

    @hybrid_property
    def geometry(self):
        return db.session.execute(self.__build_geometry()).scalar()

    @geometry.expression
    def geometry(cls):
        return __build_geometry(cls)

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
            n_samples=self.n_samples,
            covariance=self.covariance,
            axes=self.principal_axes,
            measurements=[m.id
                for m in self.measurements])

