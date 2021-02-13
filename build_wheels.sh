#!/bin/bash
set -e -x

# Python 2.7, 3.4, and 3.5 are not supported
# remove binaries if still present
rm -rf /opt/python/cp27*
rm -rf /opt/python/cp34*
rm -rf /opt/python/cp35*

# Compile wheels
for PYBIN in /opt/python/*/bin; do
    "${PYBIN}/pip" wheel . -v -w wheelhouse/ --no-deps
done

# Bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
    auditwheel repair "$whl" -w dist
done

# Source distribution
/opt/python/cp39-cp39/bin/python setup.py sdist --dist-dir=dist

# Install and test
cd test
for PYBIN in /opt/python/*/bin/; do
    "${PYBIN}/pip" install simplebloom --no-index -f ../dist
    "${PYBIN}/python" -m pytest -vv
done
cd ..
