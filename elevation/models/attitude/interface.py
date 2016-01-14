from __future__ import division
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

    axis_aligned = db.Column(ARRAY(db.Float,
        dimensions=2,zero_indexes=True))

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
        self.__regression__ = Orientation(self.centered_array)
        return self.__regression__

    def pca(self):
        """ Initialize a principal components
            analysis against the attitude.
        """
        a = self.centered_array
        return Orientation(a)

    def calculate(self):

        try:
            pca = self.pca()
        except IndexError:
            # If there aren't enough coordinates
            return

        self.axis_aligned = pca.rotated().tolist()

        self.strike, self.dip = pca.strike_dip()

        #r = N.sqrt(N.sum(N.diagonal(pca.covariance_matrix)))
        # Actually, the sum of squared errors
        # maybe should change this
        sse = N.sum(pca.rotated()[:,2]**2)
        self.correlation_coefficient = N.sqrt(sse/len(pca.rotated()))

        sv = pca.singular_values

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
