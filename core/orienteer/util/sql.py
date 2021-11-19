from shapely.wkb import loads
from binascii import unhexlify


def parse_geometry(wkb):
    """
    Parse geometry from PostGIS into a shapely
    geometry.
    """
    return loads(unhexlify(wkb.encode()))
