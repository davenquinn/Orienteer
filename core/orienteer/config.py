# Default configuration for Elevation application
from os import environ

SQLALCHEMY_DATABASE_URI = environ.get("ORIENTEER_DATABASE")
SRID = environ.get("ORIENTEER_SRID")
FOOTPRINT_SRID = environ.get("ORIENTEER_FOOTPRINT_SRID", SRID)
