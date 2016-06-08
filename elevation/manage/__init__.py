import click
from click import Group, echo, secho

from ..util.cli import execute_sql, header, message
from ..database import db

ElevationCommand = Group(
    help="Deals with elevation models")

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

@ElevationCommand.command(name='compute-footprints')
def compute_footprints():
    """
    Update footprint for each dataset based on image extent
    """
    from ..models import Dataset
    images = (db.session.query(Dataset)
            .filter_by(manage_footprint=True)
            .all())
    for image in images:
        message("Computing footprint for {}".format(image.id))
        image.compute_footprint()
        db.session.add(image)
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

