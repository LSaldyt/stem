#!/usr/bin/env python3
import subprocess, threading

from pprint     import pprint
from contextlib import contextmanager
from cord       import Cord
from backbone   import launch

GLOBAL_POOL = dict()

def init(database, notifier):
    # TODO GET ARGS
    # print(args)
    # print('init')
    thread = threading.Thread(target=lambda:launch('https://github.com/LSaldyt/cryptometric'))
    thread.start()
    GLOBAL_POOL['compare'] = thread

commandTree = dict(init=init)

if __name__ == '__main__':
    try:
        cord = Cord(commandTree)
        cord.loop()
    finally:
        for thread in GLOBAL_POOL.values():
            thread.join()
