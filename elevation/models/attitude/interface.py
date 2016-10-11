from __future__ import division
import logging as log
import numpy as N
from attitude.orientation import Orientation
from attitude.coordinates import centered
from ...database import db

from sqlalchemy.dialects.postgresql import array, ARRAY

class AttitudeInterface(object):
    strike = db.Column(db.Float)
    dip = db.Column(db.Float)
    correlation_coefficient = db.Column(db.Float)
    planarity = db.Column(db.Float)

    principal_axes = db.Column(ARRAY(db.Float,
        dimensions=2,zero_indexes=True))
    singular_values = db.Column(ARRAY(db.Float,zero_indexes=True))
    covariance = db.Column(ARRAY(db.Float,zero_indexes=True))
    n_samples = db.Column(db.Integer)

    @property
    def aligned_array(self):
        """
        Array aligned with the principal components
        of the orientation measurement.
        """
        return N.array(self.axis_aligned)

    def error_ellipse(self):
        from .plot import error_ellipse
        return error_ellipse(self)

    def plot_aligned(self):
        from attitude.display.plot import plot_aligned
        return plot_aligned(self.pca())

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

    def calculate(self):

        try:
            pca = Orientation(self.centered_array)
        except IndexError:
            # If there aren't enough coordinates
            return
        self.principal_axes = pca.axes.tolist()
        self.singular_values = pca.singular_values.tolist()
        self.covariance = N.diagonal(pca.covariance_matrix).tolist()
        self.n_samples = pca.n
        self.strike, self.dip = pca.strike_dip()

        #r = N.sqrt(N.sum(N.diagonal(pca.covariance_matrix)))
        # Actually, the sum of squared errors
        # maybe should change this
        sse = N.sum(pca.rotated()[:,2]**2)
        self.correlation_coefficient = N.sqrt(sse/len(pca.rotated()))

    def __repr__(self):
        def val(obj, s):
            try:
                return s.format(obj)
            except ValueError:
                return "unmeasured"
            except TypeError:
                return "unmeasured"
        s = "{cls} {id}: strike {s}, dip {d}, planarity {p}"\
            .format(
                cls = self.__class__.__name__,
                id = self.id,
                s = val(self.strike, "{0:.1f}"),
                d = val(self.dip, "{0:.1f}"),
                p = val(self.planarity,"{0:.2f}"))
        return s
