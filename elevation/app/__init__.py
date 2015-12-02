from flask import Flask, Blueprint, Response
from cStringIO import StringIO

from ..database import db
from .proj import init_projection

elevation = Blueprint('elevation',__name__)

def get_attitude(id):
    from ..models import Attitude, AttitudeGroup
    cls = Attitude
    try:
        id = int(id)
    except ValueError:
        if id.startswith("G"):
            cls = AttitudeGroup
        id = int(id[1:])
    return cls.query.get(id)

def image(fig):
    i_ = StringIO()
    fig.savefig(i_,
        format="png",
        bbox_inches="tight",
        dpi=300)
    i_.seek(0)
    return Response(i_.read(),
            mimetype="image/png")

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

    app.register_blueprint(elevation,url_prefix="/elevation")
    app.register_blueprint(api,url_prefix="/api")
    init_projection(app,db)

def setup_app():
    app = Flask(__name__)
    app.config.from_object('elevation.config')
    app.config.from_envvar('ELEVATION_CONFIG',silent=True)
    db.init_app(app)
    __setup_endpoints(app,db)
    return app
