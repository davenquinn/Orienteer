import click
from flask.ext.script import Manager
from click import Group, echo, secho

from syrtis.cli import execute_sql, header, message
from syrtis.core import db
from .dataset import import_datasets, build_contours
from .georeference import georeference

ElevationCommand = Group(
    help="Deals with elevation models",
    commands={
        "import-datasets": import_datasets,
        "build-contours": build_contours,
        "georeference": georeference})

@ElevationCommand.command()
def extract():
    """
    Extract elevation data from DEMs
    """
    from ..models import Attitude

    message("Initializing attitudes from features")
    execute_sql("""INSERT INTO attitude (id)
    SELECT t1.id
	FROM dataset_feature t1
	LEFT JOIN attitude t2 ON t1.id = t2.id
	WHERE t1.type = 'Attitude' AND t2.id IS NULL;""")

    q = (db.session.query(Attitude)
        .filter(Attitude.extracted == None))

    for d in q.all():
        message("Extracting attitude "+str(d.id))
        d.extract()
        d.calculate()
        db.session.add(d)
    db.session.commit()


@ElevationCommand.command()
@click.option("--extract",is_flag=True,default=False)
def recalculate(extract=False):
    from ..models import Attitude, AttitudeGroup, DatasetFeature

    heading = dict(fg="cyan", bold=True)

    if extract:
        secho("Extracting features from DEMs", **heading)
        set = DatasetFeature.query.all()
        with click.progressbar(set,length=len(set)) as bar:
            for obj in bar:
                try:
                    obj.extract()
                except AssertionError:
                    continue
                db.session.add(obj)
            db.session.commit()

    secho("Updating orientation measurements", **heading)
    set = AttitudeGroup.query.all() + Attitude.query.all()

    with click.progressbar(set,length=len(set)) as bar:
        for attitude in bar:
            attitude.calculate()
            db.session.add(attitude)
        db.session.commit()

@ElevationCommand.command()
@click.option("--rebuild", is_flag=True, default=False)
def residuals(rebuild=False):
    """
    Calculates elevation residuals from MOLA for each dataset.
    """
    from ..models import Dataset
    for dataset in Dataset.query.all():
        dataset.compute_residuals(rebuild)
