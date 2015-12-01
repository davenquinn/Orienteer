from .base import BaseModel, db

feature_tag = db.Table('feature_tag', BaseModel.metadata,
    db.Column('tag_name', db.String(64), db.ForeignKey('tag.name')),
    db.Column('feature_id', db.Integer, db.ForeignKey('dataset_feature.id',
        ondelete='CASCADE')))

attitude_group_tag = db.Table('attitude_group_tag', BaseModel.metadata,
    db.Column('tag_name', db.String(64), db.ForeignKey('tag.name')),
    db.Column('group_id', db.Integer, db.ForeignKey('attitude_group.id',
        ondelete='CASCADE')))


class Tag(BaseModel):
    name = db.Column(db.String(64), primary_key=True)
    __str__ = lambda self: self.name
    __repr__ = lambda self: "Tag {0}".format(self)

    def __init__(self, name):
        self.name = name
