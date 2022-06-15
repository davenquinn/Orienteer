import click
from click import Group, echo, secho, style, option
from collections import defaultdict
from os import path, environ

from .core import setup_app
from .config import HOST, GEOGRAPHIC_SRID
from .models import Base
from .database import db

OrienteerCommand = Group(help="Deals with elevation models")


def message(message, section=None, color="cyan"):
    s = "\n"
    s += "[" + style(section, color) + "] " if section else ""
    s += message
    echo(s)


def stored_procedure(fn, params=None):
    """
    Run SQL sourced from a file in the `sql` directory
    in this tree
    """
    here = path.dirname(__file__)
    fn = path.join(here, "sql", fn + ".sql")
    db.exec_sql(fn, params)


@OrienteerCommand.command()
@option("--skip-errors", is_flag=True, default=False)
def extract(skip_errors=False):
    """
    Extract elevation data from DEMs
    """
    from .models import DatasetFeature, Attitude

    message("Initializing attitudes from features")

    # Add dataset automatically to features
    # where it is undefined
    stored_procedure("add-dataset")
    stored_procedure("init-attitudes")
    db.session.commit()

    q = (
        db.session.query(DatasetFeature)
        .filter(DatasetFeature.extracted == None)
        .filter(DatasetFeature.dataset != None)
    )

    for d in q.all():
        message("Extracting feature " + str(d.id))
        try:
            d.extract()
            db.session.add(d)
            db.session.commit()
        except Exception as err:
            if not skip_errors:
                raise err
            message("Couldn't extract feature " + str(d.id))
            secho(str(err), fg="red")
            db.session.rollback()

    q = (
        db.session.query(Attitude)
        .join(DatasetFeature)
        .filter(DatasetFeature.extracted != None)
        .filter(Attitude.strike == None)
    )
    for d in q.all():
        message("Computing attitude data for " + str(d.id))
        try:
            d.calculate()
            db.session.add(d)
            db.session.commit()
        except AssertionError as err:
            secho(str(err), fg="red")
            db.session.rollback()


@OrienteerCommand.command(name="compute-footprints")
@click.option("--regenerate", is_flag=True, default=False)
def compute_footprints(regenerate=False):
    """
    Update footprint for each dataset based on image extent
    """
    from .models import Dataset

    images = db.session.query(Dataset)
    if not regenerate:
        # Only work on images where the footprint isn't defined
        images = images.filter(Dataset.footprint.is_(None))

    for image in images.all():
        message("Computing footprint for {}".format(image.id))
        image.compute_footprint()
        db.session.add(image)
    db.session.commit()


@OrienteerCommand.command()
@click.option("--extract", is_flag=True, default=False)
def recalculate(extract=False):
    from .models import Attitude, AttitudeGroup, DatasetFeature

    heading = dict(fg="cyan", bold=True)

    if extract:

        # Add dataset automatically to features
        # where it is undefined
        stored_procedure("add-dataset")
        stored_procedure("init-attitudes")

        secho("Extracting features from DEMs", **heading)
        set = db.session.query(DatasetFeature).all()
        with click.progressbar(set, length=len(set)) as bar:
            for obj in bar:
                try:
                    obj.extract()
                except (AssertionError, ValueError, NotImplementedError):
                    continue
                db.session.add(obj)
                db.session.commit()

    secho("Updating orientation measurements", **heading)
    set = db.session.query(Attitude).all()

    with click.progressbar(set, length=len(set)) as bar:
        for attitude in bar:
            try:
                attitude.calculate()
            except Exception:
                pass
            db.session.add(attitude)
            db.session.commit()


@OrienteerCommand.command(name="check-integrity")
def check_integrity():
    """
    Checks the integrity of computed data in the database
    """
    import numpy as N
    from .models import Attitude, AttitudeGroup

    set = db.session.query(Attitude).all()
    index = defaultdict(list)

    def equal(meas, name, *vals):
        try:
            assert N.allclose(*vals)
        except AssertionError:
            index[str(meas)].append(name)

    secho(
        "Checking data integrity for {} measurements".format(len(set)),
        fg="green",
        bold=True,
    )

    with click.progressbar(set, length=len(set)) as bar:
        for a in bar:
            pca = a.pca()
            equal(a, "principal axes", pca.axes, a.principal_axes)
            equal(a, "singular values", pca.singular_values, a.singular_values)
            equal(a, "number of samples", pca.n, a.n_samples)
            equal(a, "strike and dip", pca.strike_dip(), (a.strike, a.dip))

    if len(index) == 0:
        secho("No errors", fg="green", bold=True)
        return

    secho("Errors", fg="red", bold=True)
    for k, v in index.items():
        echo("{}: ".format(k) + ", ".join([style(str(i), fg="red") for i in v]))


@OrienteerCommand.command()
def shell():
    """
    Create a python interpreter inside
    the application.
    """
    from IPython import embed
    from . import models as m

    Orienteer = style("Orienteer", fg="green")
    echo(f"Welcome to the {Orienteer} application!")
    embed()


@OrienteerCommand.command()
def serve():
    """
    Run a basic development server for the application.
    """
    from orienteer.core import setup_app

    app = setup_app()
    with app.app_context():
        app.run(host=HOST)


@OrienteerCommand.command(name="create-tables")
def create_tables():
    """
    Create all tables used by the application.
    """
    app = setup_app()
    with app.app_context():
        db.engine.execute("CREATE SCHEMA IF NOT EXISTS orienteer")

        # Create all tables defined by SQLAlchemy ORM objects.
        Base.metadata.create_all(db.engine)
        stored_procedure("01-schema-additions")

        stored_procedure("attitude-data")
        stored_procedure(
            "create-api-views", params={"geographic_srid": GEOGRAPHIC_SRID}
        )
        # Reload PostgREST schema cache
        db.engine.execute("NOTIFY pgrst, 'reload schema'")
