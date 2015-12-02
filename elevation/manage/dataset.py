from __future__ import print_function
import os
import yaml
import click
from click import echo, style, secho

from flask import current_app as app
from ..models.dataset import Dataset
from ..database import db
from ..util.cli import execute_sql, working_directory, run, quote

hirise_datasets = lambda: (Dataset.query
        .filter_by(instrument="HiRISE")
        .all())

def build_vrt():
    """Builds virtual rasters"""
    BASEDIR = app.config.get("PROJECT_DIR")
    with working_directory(BASEDIR):
        run("mkdir -p", "virtual_mosaics")

        datasets = hirise_datasets()

        for im in ["dem","ortho","fom"]:
            fn = "{0}.tif".format(im)
            images = [quote(d.path("images",fn))
                    for d in datasets]
            cmd = [
                "gdalbuildvrt",
                "hirise_{0}.vrt".format(im),
                "-overwrite"]
            cmd += images
            run(*cmd)

def create_views():
    names = [d.id for d in hirise_datasets()]
    t = "(SELECT *, '{0}' AS src FROM contour.{0})"
    sql = " UNION ALL ".join([t.format(n) for n in names])
    query = "CREATE OR REPLACE VIEW contour.hirise AS {0};".format(sql)
    secho(query, fg="green")
    execute_sql(query)

@click.command()
@click.argument("ids",nargs=-1)
@click.option("--rebuild", is_flag=True, default=False)
@click.option("--extract",is_flag=True,default=False)
def import_datasets(ids, extract=False, rebuild=False):
    """
    Imports all datasets from configuration file,
    creating where necessary.
    """
    CONFIG_DIR = app.config.get("CONFIG_DIR")
    DB_NAME = app.config.get("DB_NAME")

    echo("["+style("Importing data", "red")+"]")

    try:
        fname = os.path.join(CONFIG_DIR,"elevation-models.yaml")
        with open(fname, "r") as f:
            data = yaml.safe_load(f)
    except ValueError, err:
        s = "Error in configuration file: {0}".format(err)
        secho(s, fg="yellow")
        return
    except IOError as err:
        echo(fname)
        secho("No configuration file found", fg="yellow")
        return

    # This prevents us from choking when changing
    # column types.
    execute_sql("DROP VIEW IF EXISTS contour.hirise;")

    for config in data:
        id = config.pop("id")
        if len(ids) > 0:
            if id not in ids:
                continue

        image = Dataset.query.get(id)
        if image is None:
            # Create if not exists
            image = Dataset(id=id)
        image.instrument = config.pop("instrument", None)
        db.session.add(image)
        db.session.commit()
        echo("["+style(image.id,fg="cyan")+"] " + image.instrument)

        image.import_data(config,rebuild=rebuild, extract=extract)
    db.session.close()

    create_views()
    build_vrt()
    run("psql", DB_NAME,"-c","'VACUUM ANALYZE;'")

@click.command()
@click.argument("ids",nargs=-1)
@click.option("--rebuild", is_flag=True, default=False)
def build_contours(ids, rebuild=False):
    qset = db.session.query(Dataset)
    if len(ids) > 0:
        qset = qset.filter(Dataset.id.in_(ids))
    for dataset in qset.all():
        dataset.build_contours(overwrite=rebuild)
    create_views()
