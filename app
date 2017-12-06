#!/usr/bin/env python3
import multiprocessing, subprocess 

from pprint     import pprint
from contextlib import contextmanager
from cord       import Cord
from backbone   import launch

GLOBAL_POOL = dict()

def get_url(name, user='LSaldyt'):
    if '.' in name or '/' in name:
        return name
    else:
        return 'https://github.com/{}/{}'.format(user, name)

def start(database, notifier, *args):
    name = args[0]
    thread = multiprocessing.Process(target=lambda:launch(get_url(name), name))
    thread.start()
    GLOBAL_POOL[name] = thread

def stop(database, notifier, *args):
    name = args[0]
    GLOBAL_POOL[name].join(1)
    GLOBAL_POOL[name].terminate()

def save_data(database):
    pass

commandTree = dict(start=start, stop=stop)

if __name__ == '__main__':
    try:
        cord = Cord(commandTree, save_data)
        cord.loop()
    finally:
        for thread in GLOBAL_POOL.values():
            thread.join()
