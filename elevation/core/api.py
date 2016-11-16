import os
from click import echo
from flask import Blueprint, request, make_response, jsonify
from json import dumps, loads
import logging

from ..database import db
from ..models import Attitude, AttitudeGroup, DatasetFeature, Tag

log = logging.getLogger(__name__)
api = Blueprint('api', __name__)

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
        rv['message'] = self.message
        return rv

@api.errorhandler(InvalidUsage)
def handle_invalid_usage(error):
    response = jsonify(error.to_dict())
    response.status_code = error.status_code
    return response

@api.errorhandler(404)
def not_found(error):
    return make_response(
        jsonify(status='error',
            message='Not found'), 404)

@api.route('/group',
    methods=["GET", "POST"])
def group():
    if request.method == "GET":
        return jsonify(
            data=[g.serialize()\
                for g in db.session.query(AttitudeGroup).all()])
    elif request.method == "POST":
        # We're going to create a group
        # Need to decode bytes; might break py2 compatibility
        data = loads(request.data.decode('utf-8'))
        features = [db.session.query(Attitude).get(i)
            for i in data["measurements"]]
        if len(features) < 2:
            msg = "Cannot create group from less than two features"
            raise InvalidUsage(msg)
        group = AttitudeGroup(features)
        db.session.add(group)
        # Delete unreferenced groups
        for g in db.session.query(AttitudeGroup).all():
            if len(g.measurements) == 0:
                db.session.delete(g)
        db.session.commit()
        return jsonify(data=group.serialize())

@api.route('/group/<id>',
    methods=["DELETE","POST"])
def update_group(id):
    group = db.session.query(AttitudeGroup).get(id)
    if request.method == "DELETE":
        db.session.delete(group)
        db.session.commit()
        return jsonify(status="success")
    if request.method == "POST":
        data = loads(request.data.decode('utf-8'))
        group.same_plane = data["same_plane"]
        group.calculate()
        db.session.add(group)
        db.session.commit()
        return jsonify(data=group.serialize())

@api.route("/attitude", methods=["GET"])
def data():
    log.info("Serializing attitude data")
    d = jsonify(
        data=[o.serialize()
        for o in db.session.query(Attitude)
            .filter_by(type='single')
            .all()])
    log.info(d)
    return d
