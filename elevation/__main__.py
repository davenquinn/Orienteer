from click import echo, style
from elevation.manage import ElevationCommand
from . import app, db
from os import path

__dirname = path.dirname(__file__)

@ElevationCommand.command()
def shell():
    """
    Create a python interpreter inside
    the application.
    """
    from IPython import embed
    from . import models as m
    _ = style("Elevation",fg="green")
    echo("Welcome to the "+_+" application!")
    embed()

@ElevationCommand.command()
def serve():
    """
    Run a basic development server for the application.
    """
    from elevation.core import setup_app
    app = setup_app()
    with app.app_context():
        app.run()

@ElevationCommand.command(name='create-tables')
def create_tables():
    """
    Create all tables used by the application.
    """
    from elevation.core import setup_app
    app = setup_app()
    with app.app_context():
        db.create_all()
        sql = path.join(__dirname,'../frontend/sql/attitude-data.sql')
        query = open(sql).read()
        db.engine.execute(query)

ElevationCommand()
