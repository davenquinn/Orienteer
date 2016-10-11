from .dataset import Dataset
from .feature import DatasetFeature
from .attitude import Attitude, AttitudeGroup, Tag

def get_attitude(id):
    cls = Attitude
    try:
        id = int(id)
    except ValueError:
        if id.startswith("G"):
            cls = AttitudeGroup
        id = int(id[1:])
    if id < 0:
        # We are using the negative-number representation
        # for group ids
        cls = AttitudeGroup
        id *= -1
    return cls.query.get(id)
