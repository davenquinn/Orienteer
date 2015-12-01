from flask import render_template, Blueprint, Response, jsonify
from cStringIO import StringIO

from ..database import db
from ..models import Attitude, AttitudeGroup
from .api import api

elevation = Blueprint('elevation',
        __name__,
        template_folder="templates")

@elevation.route("/")
def index():
    return render_template("elevation/index.html")

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
