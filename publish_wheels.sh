#!/bin/bash
set -e -x

PYBIN=/opt/python/cp39-cp39/bin
"${PYBIN}/pip" install twine
"${PYBIN}/python" -m twine upload \
    --skip-existing \
    --disable-progress-bar \
    --non-interactive \
    dist/*
