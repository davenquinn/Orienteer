import numpy as N
from functools import partial
from click import echo

import rasterio
from rasterio.features import rasterize, geometry_mask
from affine import Affine

from imagery.strategies import bilinear
from subdivide import subdivide
from sqlalchemy.dialects.postgresql import array
from geoalchemy2.shape import from_shape, to_shape
from shapely.geometry import shape, mapping, asShape, LineString
from shapely.ops import transform

from ...app.proj import Projection, transformation

def clean_coordinates(coords, silent=False):
    """
    Removes invalid coordinates (this is generally caused
    by importing coordinates outside of the DEM)
    """
    l1 = len(coords)
    coords = coords[~N.isnan(coords).any(axis=1)] # remove NaN values
    l2 = len(coords)
    if not silent:
        msg = "{0} coordinates".format(l2)
        if l2 < l1:
            msg += " ({0} removed as invalid)".format(l1-l2)
        echo(msg)
    return coords

def offset_mask(mask):
    """ Returns a mask shrunk to the 'minimum bounding rectangle' of the
        nonzero portion of the previous mask, and its offset from the original.
        Useful to find the smallest rectangular section of the image that can be
        extracted to include the entire geometry. Conforms to the y-first
        expectations of numpy arrays rather than x-first (geodata).
    """
    def axis_data(axis):
        """Gets the bounds of a masked area along a certain axis"""
        x = mask.sum(axis)
        trimmed_front = N.trim_zeros(x,"f")
        offset = len(x)-len(trimmed_front)
        size = len(N.trim_zeros(trimmed_front,"b"))
        return offset,size

    xo,xs = axis_data(0)
    yo,ys = axis_data(1)

    array = mask[yo:yo+ys,xo:xo+xs]
    offset = (yo,xo)
    return offset, array

def extract(self):
    source_crs = Projection.query.get(self.geometry.srid).crs
    demfile = self.dataset.path("images","dem.tif")

    with rasterio.open(demfile) as dem:

        # Transform the shape to the DEM's projection
        projection = transformation(source_crs, dem.crs)
        geom = transform(projection,
                to_shape(self.original_geometry))

        if geom.area == 0:

            # Transform geometry into pixels
            f = lambda *x: ~dem.affine * x
            px = transform(f,geom)

            # Subdivide geometry segments
            # at 1-pixel intervals
            px = subdivide(px, interval=1)

            band = dem.read(1)
            extracted = bilinear(band, px)
            coords = N.array(extracted.coords)

            # Transform pixels back to geometry
            # to capture subdivisiones
            f = lambda *x: dem.affine * (x[0],x[1])
            geom = transform(f,extracted)

            coords[:,:2] = N.array(geom.coords)

        else:

            # RasterIO's image-reading algorithm uses the location
            # of polygon centers to determine the extent of polygons
            msk = geometry_mask(
                (mapping(geom),),
                dem.shape,
                dem.affine,
                invert=True)

            # shrink mask to the minimal area for efficient extraction
            offset, msk = offset_mask(msk)

            window = tuple((o,o+s)
                for o,s in zip(offset,msk.shape))

            # Currently just for a single band
            # We could generalize to multiple
            # bands if desired
            z = dem.read(1,
                window=window,
                masked=True)

            # mask out unused area
            z[msk == False] = N.ma.masked

            # Make vectors of rows and columns
            rows, cols = (N.arange(first,last,1)
                    for first,last in window)
            # 2d arrays of x,y,z
            z = z.flatten()
            xyz = [i.flatten()
                    for i in N.meshgrid(cols,rows)] + [z]
            x,y,z = tuple(i[z.mask == False] for i in xyz)

            # Transform into 3xn matrix of
            # flattened coordinate values
            coords = N.vstack((x,y,N.ones(z.shape)))

            # Get affine transform for pixel centers
            affine = dem.affine * Affine.translation(0.5, 0.5)
            # Transform coordinates to DEM's reference
            _ = N.array(affine).reshape((3,3))
            coords = N.dot(_,coords)
            coords[2] = z
            coords = coords.transpose()

            # Transform coordinates back to transverse mercator?
            # (not currently implemented)

    coords = clean_coordinates(coords, silent=True)
    assert len(coords) > 0
    self.extracted = coords.tolist()
