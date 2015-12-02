from app import setup_app
from IPython import embed
from click import echo, style

from .manage import ElevationCommand

@ElevationCommand.command()
def shell():
    """
    Create a python interpreter inside
    the application.
    """
    from . import models as m
    _ = style("Elevation",fg="green")
    echo("Welcome to the "+_+" application!")
    embed()

app = setup_app()
with app.app_context():
    ElevationCommand()
