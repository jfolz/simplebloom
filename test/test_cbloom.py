import os
import sys
import importlib

# make sure module is loaded with Python version#
os.unsetenv('SIMPLEBLOOM_USEPY')
if 'simplebloom' in sys.modules:
    importlib.reload(sys.modules['simplebloom'])

from common import add, check

from simplebloom.bloom import PURE_PYTHON
assert not PURE_PYTHON


def test_add_native_10():
    add(10)


def test_add_native_100():
    add(100)


def test_add_native_1000():
    add(1000)


def test_add_native_10000():
    add(10000)


def test_add_native_100000():
    add(100000)


def test_check_native_10():
    check(10)


def test_check_native_100():
    check(100)


def test_check_native_1000():
    check(1000)


def test_check_native_10000():
    check(10000)


def test_check_native_100000():
    check(100000)
