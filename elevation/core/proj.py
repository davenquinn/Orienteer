import logging as log
from pg_projector import PGProjector, transformation, srid

# Setup common SRIDs from configuration
Projection = None
def init_projection(app, db):
    Projection = PGProjector(app, db)
    log.debug("Set up projection")
