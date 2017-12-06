#!/usr/bin/env python3
import multiprocessing, subprocess 

from pprint     import pprint
from contextlib import contextmanager
from cord       import Cord
from backbone   import launch

GLOBAL_POOL = dict()

def start(database, notifier, *args):
    name = args[0]
    thread = multiprocessing.Process(target=lambda:launch('https://github.com/LSaldyt/{}'.format(name)))
    thread.start()
    GLOBAL_POOL[name] = thread

def stop(database, notifier, *args):
    name = args[0]
    GLOBAL_POOL[name].join(1)
    GLOBAL_POOL[name].terminate()

commandTree = dict(init=init)

if __name__ == '__main__':
    try:
        cord = Cord(commandTree)
        cord.loop()
    finally:
        for thread in GLOBAL_POOL.values():
            thread.join()
