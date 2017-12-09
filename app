#!/usr/bin/env python3
import multiprocessing, subprocess, os

from pprint     import pprint
from contextlib import contextmanager
from cord       import Cord

GLOBAL_POOL = dict()

@contextmanager
def directory(name):
    original = os.getcwd()
    os.chdir(name)
    try:
        yield
    finally:
        os.chdir(original)

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
        GLOBAL_POOL[name].kill()
    appDir = 'apps/' + name
    if not os.path.isdir(appDir):
        subprocess.call(['git', 'clone', get_url(name), appDir])
    with directory(appDir):
        subprocess.call(['git', 'pull'])
        GLOBAL_POOL[name] = subprocess.Popen(['./app'])

def stop(database, notifier, *args):
    name = args[0]
    p = GLOBAL_POOL[name]
    pid = p.pid
    p.terminate()
    # Check if the process has really terminated & force kill if not.
    try:
        os.kill(pid, 0)
        p.kill()
        print("Forced kill")
    except OSError as e:
        print("Terminated gracefully")

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
            thread.kill()
