import sys
import logging
from functools import wraps
from flask import Flask, Blueprint, Response, render_template
from os import environ
from json import load
from .proj import init_projection

# Python 2 and 3 compatibility
try:
    from io import BytesIO
except ImportError:
    from cStringIO import StringIO as BytesIO

from ..database import db

stdout_logger = logging.StreamHandler(sys.stdout)
log = logging.getLogger(__name__)
log.setLevel(logging.INFO)
# log.addHandler(stdout_logger)

log2 = logging.getLogger("attitude")
log2.setLevel(logging.INFO)

elevation = Blueprint("elevation", __name__)


def get_attitude(id):
    from ..models import Attitude

    return db.session.query(Attitude).get(id)


def image(fig):
    i_ = BytesIO()
    fig.savefig(i_, format="png", bbox_inches="tight", dpi=300)
    i_.seek(0)
    return Response(i_.read(), mimetype="image/png")


@elevation.route("/attitude/<id>/data.html")
def attitude_data(id):
    import numpy as N

    attitude = get_attitude(id)
    pca = attitude.pca()
    return render_template(
        "data-area.html",
        id=id,
        server_url="http://localhost:8000",
        a=attitude,
        pca=pca,
        angular_errors=tuple(N.degrees(i) for i in pca.angular_errors()[::-1]),
    )


@elevation.route("/attitude/<id>/errorbars.png")
def errorbars(id):
    from attitude.plot import error_comparison

    attitude = get_attitude(id)
    fig = error_comparison(attitude.pca(), do_bootstrap=False)
    return image(fig)


@elevation.route("/attitude/<id>/axis-aligned.png")
def principal_components(id):
    attitude = get_attitude(id)
    fig = attitude.plot_aligned()
    return image(fig)


@elevation.route("/attitude/<id>/error.png")
def error_ellipse(id):
    attitude = get_attitude(id)
    fig = attitude.error_ellipse()
    return image(fig)


def __setup_endpoints(app, db):
    from .api import api

    app.register_blueprint(elevation, url_prefix="/elevation")
    app.register_blueprint(api, url_prefix="/api")

    @app.route("/")
    def index():
        return dict(success=True, message="Welcome to the Orienteer application!")


SRID = None


def setup_app(with_api=True):
    app = Flask(__name__)
    app.config.from_object("orienteer.config")
    cfg_file = environ.get("ORIENTEER_CONFIG")
    if cfg_file is not None:
        with open(cfg_file) as f:
            cfg = load(f)
            cfg["SRID"] = cfg["srid"]
            cfg["SQLALCHEMY_DATABASE_URI"] = cfg.get("database_uri", None)
        app.config.update(cfg)
    global SRID
    SRID = app.config.get("srid")
    if with_api:
        init_projection(app, db)

        __setup_endpoints(app, db)
        log.info("App setup complete")

    def within_context(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            with app.app_context():
                return func(*args, **kwargs)

        return wrapper

    app.context = within_context

    return app
