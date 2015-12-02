# -*- coding:utf-8 -*-

from syrtis.cli import *

from ..database import db

def execute_sql(statement):
    echo(u"➔ "+style(statement, "yellow"))
    return db.engine.execute(statement)
