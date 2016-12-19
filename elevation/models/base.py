from ..database import db
from sqlalchemy.orm import object_session
from sqlalchemy.ext.declarative import declarative_base
from click import echo

Base = declarative_base()

class BaseModel(Base):
    __abstract__ = True
    @classmethod
    def get_or_create(cls, **kwargs):
        instance = db.session.query(cls).filter_by(**kwargs).first()
        if instance:
            echo("{0} already exists".format(cls.__name__))
            return instance, False
        else:
            echo("Creating {0}...".format(cls.__name__), nl=None)
            instance = cls(**kwargs)
            db.session.add(instance)
            db.session.commit()
            return instance, True

    @property
    def session(self):
        return object_session(self)
