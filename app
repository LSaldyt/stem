#!/usr/bin/env python3
import multiprocessing, subprocess, os

from pprint     import pprint
from contextlib import contextmanager
from cord       import Cord

GLOBAL_POOL = dict()

@contextmanager
def directory(name):
    os.chdir(name)
    try:
        yield
    finally:
        os.chdir('..')

def get_sha():
    output = subprocess.check_output(['git', 'rev-parse', 'HEAD'])
    return output.decode('utf-8').strip()

def get_url(name, user='LSaldyt'):
    if '.' in name or '/' in name:
        return name
    else:
        return 'https://github.com/{}/{}'.format(user, name)

def start(database, notifier, *args):
    name = args[0]
    if name in GLOBAL_POOL:
        GLOBAL_POOL[name].terminate()
    def launch(name):
        subprocess.call(['git', 'clone', get_url(name), name])
        with directory(name):
            subprocess.call(['bash', 'run.sh'])
    thread = multiprocessing.Process(target=lambda:launch(name))
    thread.start()
    GLOBAL_POOL[name] = thread

def stop(database, notifier, *args):
    name = args[0]
    GLOBAL_POOL[name].join(1)
    GLOBAL_POOL[name].terminate()

def status(database):
    print('Cord..')
    print(GLOBAL_POOL)

def save_data(database):
    pass

commandTree = dict(start=start, stop=stop)

if __name__ == '__main__':
    try:
        cord = Cord(commandTree, save_data, status)
        cord.loop()
    finally:
        for thread in GLOBAL_POOL.values():
            thread.terminate()
