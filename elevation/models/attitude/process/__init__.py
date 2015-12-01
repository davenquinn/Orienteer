from .. import Attitude

def process_attitudes(features):
    for feature in features:
        a, created = Attitude.get_or_create(id=feature.id)
        print(a.geometry)
