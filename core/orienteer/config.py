# Default configuration for Elevation application
from os import environ

ORIENTEER_DATABASE = environ.get("ORIENTEER_DATABASE")
SQLALCHEMY_DATABASE_URI = ORIENTEER_DATABASE
SRID = environ.get("ORIENTEER_SRID")
GEOGRAPHIC_SRID = int(environ.get("ORIENTEER_GEOGRAPHIC_SRID", "4326"))
HOST = environ.get("ORIENTEER_HOST", "127.0.0.1")
