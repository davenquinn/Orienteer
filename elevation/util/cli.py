# -*- coding:utf-8 -*-

import os
from click import echo, style, secho
from subprocess import call
from shlex import split
import contextlib

from ..database import db

def header(message, color="red"):
    secho("\n◉ "+style(message, bold=True), fg=color)

def message(message, section=None, color="cyan"):
    s = "\n"
    s += "["+style(section, color)+"] " if section else ""
    s += message
    echo(s)

def run(*command, **kwargs):
    """
    Runs a command safely in the terminal,
    only initializing a subshell if specified.
    """
    shell = kwargs.pop("shell",False)
    command = " ".join(command)
    echo(u"➔ "+style(command,"green"))
    if shell:
        call(command,shell=True)
    else:
        call(split(command))

def quote(arg):
    """
    Wraps a shell argument in single quotes
    for compatibility.
    """
    return "'{}'".format(arg)

def execute_sql(statement,*params, **multiparams):
    echo(u"➔ "+style(statement, "yellow"))
    return db.engine.execute(statement,*params, **multiparams)

def mkdirs(path):
    try:
        path.mkdir(parents=True)
    except Exception:
        pass
    return path

@contextlib.contextmanager
def working_directory(path):
    """A context manager which changes the working directory to the given
    path, and then changes it back to its previous value on exit.
    """
    prev_cwd = os.getcwd()
    os.chdir(path)
    yield
    os.chdir(prev_cwd)

