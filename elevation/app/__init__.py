from flask import Flask, Blueprint, Response
from cStringIO import StringIO

from ..database import db
from ..models import Attitude, AttitudeGroup
from .api import api
from .proj import init_projection

elevation = Blueprint('elevation',__name__)

def get_attitude(id):
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

def setup_app():
    app = Flask(__name__)
    app.register_blueprint(elevation,url_prefix="/elevation")
    app.register_blueprint(api,url_prefix="/api")
    app.config.from_object('elevation.config')
    app.config.from_envvar('ELEVATION_CONFIG',silent=True)
    db.init_app(app)
    init_projection(app,db)
    return app
