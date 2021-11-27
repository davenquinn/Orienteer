# Default configuration for Elevation application
from os import environ

ORIENTEER_DATABASE = environ.get("ORIENTEER_DATABASE")
SQLALCHEMY_DATABASE_URI = ORIENTEER_DATABASE
SRID = environ.get("ORIENTEER_SRID")
FOOTPRINT_SRID = environ.get("ORIENTEER_FOOTPRINT_SRID", SRID)
HOST = environ.get("ORIENTEER_HOST", "127.0.0.1")
