import subprocess
import os
import errno
import functools
import shlex
from click import echo, style

from .cli import run, quote, message, header, execute_sql, working_directory

def listify(f):
    @functools.wraps(f)
    def listify_helper(*args, **kwargs):
        return list(f(*args, **kwargs))
    return listify_helper

def makedirs(path):
    try:
        os.makedirs(path)
    except OSError as exception:
        if exception.errno != errno.EEXIST:
            raise
