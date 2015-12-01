from syrtis.core import app
from .manage import ElevationCommand

with app.app_context():
    ElevationCommand()
