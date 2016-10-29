from ..base import BaseModel, db
from sqlalchemy import (
    Table, Column, String, Text,
    Integer, ForeignKey)

attitude_tag = Table('attitude_tag', BaseModel.metadata,
    Column('tag_name', String(64), ForeignKey('tag.name')),
    Column('attitude_id', Integer, ForeignKey('attitude.id',
        ondelete='CASCADE')))

class Tag(BaseModel):
    __tablename__ = "tag"
    name = Column(String(64), primary_key=True)
    __str__ = lambda self: self.name
    __repr__ = lambda self: "Tag {0}".format(self)

    def __init__(self, name):
        self.name = name
