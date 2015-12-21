from IPython import embed
from click import echo, style

from elevation import app
from elevation.manage import ElevationCommand

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

@ElevationCommand.command()
def serve():
    """
    Run a basic development server for the application.
    """
    app.run()

with app.app_context():
    ElevationCommand()
