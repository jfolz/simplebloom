#!/bin/bash
set -e -x

echo "Selected Python versions:"
echo ${PYVERS}

# install pyenv
brew install pyenv
eval "$(pyenv init --path)"

# Compile wheels
for PYVER in ${PYVERS}; do
    pyenv install "${PYVER}"
    pyenv global "${PYVER}"
    python -m pip install -U pip
    python -m pip install -q build
    python -m build --wheel --outdir wheelhouse
done

# Bundle external shared libraries into the wheels
pyenv global 3.9-dev
python -m pip install delocate
for whl in wheelhouse/*.whl; do
    python -m delocate.cmd.delocate_wheel -w dist -v "${whl}"
done

# Install and test
cd test
for PYVER in ${PYVERS}; do
    pyenv global "${PYVER}"
    pip install --only-binary ":all:" -r ../test_requirements.txt
    pip install simplejpeg --no-index -f ../dist
    python -m pytest -vv
done
cd ..
