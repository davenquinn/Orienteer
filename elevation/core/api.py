import os
from click import echo
from flask import Blueprint, request, make_response, jsonify
from json import dumps

from ..database import db
from ..models import Attitude, AttitudeGroup, DatasetFeature, Tag

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

def tag_items(items, tagname, method):
    """ Add tags to items of any type that support the
        tagging interface.
    """
    tag = Tag.query.get(tagname)
    if not tag:
        tag = Tag(tagname)
        db.session.add(tag)

    for f in items:
        tagged = tag in f._tags
        if method == "DELETE" and tagged:
            f._tags.remove(tag)
        if method == "POST" and not tagged:
            f._tags.append(tag)
    db.session.commit()

    return jsonify(status="success", tag=tagname, items=[i.serialize()
        for i in items])

def get_ids(model,ids):
    """ Get objects given a list of IDs"""
    if len(ids) == 0:
        return []
    return model.query\
        .filter(model.id.in_(ids)).all()

@api.route('/feature/tag', methods=["POST","DELETE"])
def feature_tag():
    data = request.json
    features = get_ids(DatasetFeature,data["features"])
    return tag_items(features,data["tag"], request.method)

@api.route('/group/tag', methods=["POST","DELETE"])
def group_tag():
    data = request.json
    groups = get_ids(AttitudeGroup,data["groups"])
    return tag_items(groups,data["tag"], request.method)

@api.route('/attitude/tag', methods=["POST","DELETE"])
def attitude_tag():
    data = request.json

    features,groups = [],[]
    for f in data["features"]:
        try:
            group = f.startswith("G")
        except AttributeError:
            group = False
        if group:
            groups.append(int(f[1:]))
        else:
            features.append(int(f))
    features = get_ids(DatasetFeature,features)
    groups = get_ids(AttitudeGroup,groups)
    return tag_items(features+groups,data["tag"], request.method)

@api.route('/group',
    methods=["GET", "POST"])
def group():
    if request.method == "GET":
        return jsonify(
            data=[g.serialize()\
                for g in AttitudeGroup.query.all()])
    elif request.method == "POST":
        data = request.get_json()
        features = [Attitude.query.get(i)\
            for i in data["measurements"]]
        if len(features) < 2:
            msg = "Cannot create group from less than two features"
            raise InvalidUsage(msg)
        group = AttitudeGroup(features)
        db.session.add(group)
        # Delete unreferenced groups
        for g in AttitudeGroup.query.all():
            if len(g.measurements) == 0:
                db.session.delete(g)
        db.session.commit()
        return jsonify(data=group.serialize())

@api.route('/group/<id>',
    methods=["DELETE","POST"])
def update_group(id):
    group = AttitudeGroup.query.get(id)
    if request.method == "DELETE":
        db.session.delete(group)
        db.session.commit()
        return jsonify(status="success")
    if request.method == "POST":
        data = request.get_json()
        group.same_plane = data["same_plane"]
        group.calculate()
        db.session.add(group)
        db.session.commit()
        return jsonify(data=group.serialize())

@api.route("/attitude", methods=["GET"])
def data():
    return jsonify(
        data=[o.serialize()
        for o in Attitude.query.all()])
