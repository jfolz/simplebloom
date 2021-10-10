# do not stop on errors, manually catch errors based on exit code
$ErrorActionPreference = "Continue";

# the list of Python interpreters
$pyvers = $env:PYVERS -split "|"

Echo "Selected Python versions:"
Echo $pyvers

Echo "Choco args:"
Echo $chocoargs

# Compile & test wheels
foreach ($pyver in $pyvers){
    # install
    & choco install python3 $chocoargs -r -y --version=$pyver
    if ($LASTEXITCODE -ne 0) { throw "build failed with exit code $LASTEXITCODE" }
    refreshenv
    & python -m pip install -U pip --no-warn-script-location
    if ($LASTEXITCODE -ne 0) { throw "build failed with exit code $LASTEXITCODE" }
    & python -m pip install -q build
    # build
    if ($LASTEXITCODE -ne 0) { throw "build failed with exit code $LASTEXITCODE" }
    & python -m build --wheel  --outdir dist
    if ($LASTEXITCODE -ne 0) { throw "build failed with exit code $LASTEXITCODE" }
    # test
    cd test
    & python -m pip install --only-binary ":all:" -r ..\test_requirements.txt --no-warn-script-location
    if ($LASTEXITCODE -ne 0) { throw "build failed with exit code $LASTEXITCODE" }
    & python -m pip install simplebloom --no-index -f ..\dist
    if ($LASTEXITCODE -ne 0) { throw "build failed with exit code $LASTEXITCODE" }
    & python -m pytest -vv
    if ($LASTEXITCODE -ne 0) { throw "test failed with exit code $LASTEXITCODE" }
    cd ..
}
