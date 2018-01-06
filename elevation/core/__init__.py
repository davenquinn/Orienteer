import sys
import logging
from functools import wraps
from flask import Flask, Blueprint, Response, render_template

# Python 2 and 3 compatibility
try:
    from io import BytesIO
except ImportError:
    from cStringIO import StringIO as BytesIO

from ..database import db
from .proj import init_projection

stdout_logger = logging.StreamHandler(sys.stdout)
log = logging.getLogger(__name__)
log.setLevel(logging.INFO)
#log.addHandler(stdout_logger)

log2 = logging.getLogger('attitude')
log2.setLevel(logging.INFO)

elevation = Blueprint('elevation',__name__)

def get_attitude(id):
    from ..models import Attitude
    return db.session.query(Attitude).get(id)

def image(fig):
    i_ = BytesIO()
    fig.savefig(i_,
        format="png",
        bbox_inches="tight",
        dpi=300)
    i_.seek(0)
    return Response(i_.read(),
            mimetype="image/png")

@elevation.route("/attitude/<id>/data.html")
def attitude_data(id):
    import numpy as N
    attitude = get_attitude(id)
    pca = attitude.pca()
    return render_template("data-area.html",
            id=id,
            server_url="http://localhost:8000",
            a=attitude,
            pca=pca,
            angular_errors=tuple(N.degrees(i)
                for i in pca.angular_errors()[::-1]))

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
    init_projection(app,db)
    from .api import api
    app.register_blueprint(elevation,url_prefix="/elevation")
    app.register_blueprint(api,url_prefix="/api")

SRID = None

def setup_app():
    app = Flask(__name__)
    app.config.from_object('elevation.config')
    app.config.from_envvar('ELEVATION_CONFIG',silent=True)
    global SRID
    SRID = app.config.get("SRID")
    db.init_app(app)
    __setup_endpoints(app,db)
    log.info("App setup complete")

    def within_context(func):
        @wraps(func)
        def wrapper(*args,**kwargs):
            with app.app_context():
                return func(*args,**kwargs)
        return wrapper

    app.context = within_context

    return app
