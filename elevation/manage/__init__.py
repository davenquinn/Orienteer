import click
from click import Group, echo, secho, style
import numpy as N
from collections import defaultdict

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
    set = Attitude.query.all()

    with click.progressbar(set,length=len(set)) as bar:
        for attitude in bar:
            attitude.calculate()
            db.session.add(attitude)
        db.session.commit()

@ElevationCommand.command(name='check-integrity')
def check_integrity():
    """
    Checks the integrity of computed data in the database
    """
    from ..models import Attitude, AttitudeGroup

    set = Attitude.query.all()
    index = defaultdict(list)

    def equal(meas, name, *vals):
        try:
            assert N.allclose(*vals)
        except AssertionError:
            index[str(meas)].append(name)

    secho("Checking data integrity for {} measurements".format(len(set)),
          fg='green',bold=True)

    with click.progressbar(set,length=len(set)) as bar:
        for a in bar:
            pca = a.pca()
            equal(a,"principal axes",pca.axes, a.principal_axes)
            equal(a,"singular values",pca.singular_values, a.singular_values)
            equal(a,"covariance",N.diagonal(pca.covariance_matrix), a.covariance)
            equal(a,"number of samples",pca.n, a.n_samples)
            equal(a,"strike and dip",pca.strike_dip(),(a.strike,a.dip))

    secho("Errors",fg="red",bold=True)
    for k,v in index.items():
        echo("{}: ".format(k)+", ".join([
            style(str(i),fg='red') for i in v]))

