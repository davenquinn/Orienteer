import os
from click import echo
from flask import Blueprint, request, make_response, jsonify
from json import dumps, loads
import logging
from functools import wraps

from ..database import db
from ..models import Attitude, AttitudeGroup, DatasetFeature, Tag

log = logging.getLogger(__name__)
api = Blueprint("api", __name__)


def handle_errors(f):
    @wraps(f)
    def wrapped(*args, **kwargs):
        try:
            response = f(*args, **kwargs)
            response["status"] = "success"
        except Exception as err:
            db.session.rollback()
            response = dict()
            res = jsonify(status="failure", message=str(err))
            res.status_code = 500
            return res
        return jsonify(**response)

    return wrapped


class InvalidUsage(Exception):
    status_code = 400

    def __init__(self, message, status_code=None, payload=None):
        Exception.__init__(self)
        self.message = message
        if status_code is not None:
            self.status_code = status_code
        self.payload = payload

    def to_dict(self):
        rv = dict(self.payload or ())
        rv["message"] = self.message
        return rv


@api.errorhandler(InvalidUsage)
def handle_invalid_usage(error):
    response = jsonify(error.to_dict())
    response.status_code = error.status_code
    return response


@api.errorhandler(404)
def not_found(error):
    return make_response(jsonify(status="error", message="Not found"), 404)


@api.route("/group", methods=["POST"])
@handle_errors
def group():
    # We're going to create a group
    # Need to decode bytes; might break py2 compatibility
    data = loads(request.data.decode("utf-8"))
    features = []
    for id in data["measurements"]:
        obj = db.session.query(Attitude).get(id)
        if hasattr(obj, "measurements"):
            features += obj.measurements
        else:
            features.append(obj)
    if len(features) < 2:
        msg = "Cannot create group from less than two features"
        raise InvalidUsage(msg)
    log.info("Creating group from {} features".format(len(features)))
    group = AttitudeGroup(features, same_plane=data.get("same_plane", False))
    db.session.add(group)
    # Delete unreferenced groups
    deleted_ids = []
    for g in db.session.query(AttitudeGroup).all():
        if len(g.measurements) == 0:
            deleted_ids.append(g.id)
            db.session.delete(g)
    db.session.commit()
    return dict(data=group.serialize(), deleted_groups=deleted_ids)


@api.route("/group/<id>", methods=["DELETE", "POST"])
@handle_errors
def update_group(id):
    group = db.session.query(AttitudeGroup).get(id)
    if request.method == "DELETE":
        features = group.measurements
        # Save IDs for reconstructing groups
        ids = [m.id for m in features]
        log.info("Destroying group from {} features".format(len(features)))
        db.session.delete(group)
        db.session.commit()
        return dict(id=id, measurements=ids)
    if request.method == "POST":
        data = loads(request.data.decode("utf-8"))
        group.same_plane = data["same_plane"]
        group.calculate()
        db.session.add(group)
        db.session.commit()
        return dict(data=group.serialize())


@api.route("/attitude", methods=["GET"])
def data():
    log.info("Serializing attitude data")
    return jsonify(
        data=[
            o.serialize()
            for o in db.session.query(Attitude)
            # Descending order to put groups last
            # This is bit of a hack
            .order_by(Attitude.type.desc()).all()
        ]
    )
