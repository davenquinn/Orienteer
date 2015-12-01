from pg_projector import PGProjector, transformation, srid

from . import app, db

# Setup common SRIDs from configuration
Projection = PGProjector(app, db)
