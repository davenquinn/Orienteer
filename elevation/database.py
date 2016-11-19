from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

class Database(object):
    def init_app(self, app):
        uri = app.config.get("SQLALCHEMY_DATABASE_URI")
        self.create_session(uri)

    def create_session(self, uri, options=None):
        self.engine = create_engine(uri)
        # create a configured "Session" class
        Session = sessionmaker(bind=self.engine)
        # create a Session
        self.session = Session()
        return self.session

db=Database()
