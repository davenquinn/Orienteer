from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

class Database(object):
    def __init__(self):
        self.create_session()

    def create_session(self, options=None):
        self.engine = create_engine('postgresql:///syrtis')
        # create a configured "Session" class
        Session = sessionmaker(bind=self.engine)
        # create a Session
        self.session = Session()

db=Database()
