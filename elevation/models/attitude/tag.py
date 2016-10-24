from ..base import BaseModel, db

attitude_tag = db.Table('attitude_tag', BaseModel.metadata,
    db.Column('tag_name', db.String(64), db.ForeignKey('tag.name')),
    db.Column('attitude_id', db.Integer, db.ForeignKey('attitude.id',
        ondelete='CASCADE')))

class Tag(BaseModel):
    name = db.Column(db.String(64), primary_key=True)
    __str__ = lambda self: self.name
    __repr__ = lambda self: "Tag {0}".format(self)

    def __init__(self, name):
        self.name = name
