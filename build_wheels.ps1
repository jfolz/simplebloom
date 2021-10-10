# do not stop on errors, manually catch errors based on exit code
$ErrorActionPreference = "Continue";

# the list of Python interpreters
$pyvers = $Env:PYVERS -split ";"
$chocoargs = $Env:CHOCOARGS -split " "

Echo "Selected Python versions:"
Echo $Env:PYVERS

Echo "Choco args:"
Echo $Env:CHOCOARGS

$pydir = "C:\chocopython"

# Compile & test wheels
foreach ($pyver in $pyvers){
    # install
    & choco install python3 -y -r --force --no-progress --version=$pyver $chocoargs --params "/InstallDir:$pydir"
    if ($LASTEXITCODE -ne 0) { throw "build failed with exit code $LASTEXITCODE" }
    & $pydir\python.exe -m pip install -U pip --no-warn-script-location
    if ($LASTEXITCODE -ne 0) { throw "build failed with exit code $LASTEXITCODE" }
    & $pydir\python.exe -m pip install -q build
    # build
    if ($LASTEXITCODE -ne 0) { throw "build failed with exit code $LASTEXITCODE" }
    & $pydir\python.exe -m build --wheel  --outdir dist
    if ($LASTEXITCODE -ne 0) { throw "build failed with exit code $LASTEXITCODE" }
    # test
    cd test
    & $pydir\python.exe -m pip install --only-binary ":all:" -r ..\test_requirements.txt --no-warn-script-location
    if ($LASTEXITCODE -ne 0) { throw "build failed with exit code $LASTEXITCODE" }
    & $pydir\python.exe -m pip install simplebloom --no-index -f ..\dist
    if ($LASTEXITCODE -ne 0) { throw "build failed with exit code $LASTEXITCODE" }
    & $pydir\python.exe -m pytest -vv
    if ($LASTEXITCODE -ne 0) { throw "test failed with exit code $LASTEXITCODE" }
    cd ..
    # cleanup env
    & choco uninstall python3 -y -r --no-progress
    Remove-Item -Force -Recurse -Path "$pydir"
}
