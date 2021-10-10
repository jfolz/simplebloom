# do not stop on errors, manually catch errors based on exit code
$ErrorActionPreference = "Continue";

# the list of Python interpreters
$pyvers = $Env:PYVERS -split "|"
$chocoargs = $Env:CHOCOARGS -split " "

Echo "Selected Python versions:"
Echo $Env:PYVERS

Echo "Choco args:"
Echo $Env:CHOCOARGS

# Compile & test wheels
foreach ($pyver in $pyvers){
    # install
    & choco install python3 -y -r --force --no-progress --version=$pyver $chocoargs
    if ($LASTEXITCODE -ne 0) { throw "build failed with exit code $LASTEXITCODE" }
    & C:\python\python.exe -m pip install -U pip --no-warn-script-location
    if ($LASTEXITCODE -ne 0) { throw "build failed with exit code $LASTEXITCODE" }
    & C:\python\python.exe -m pip install -q build
    # build
    if ($LASTEXITCODE -ne 0) { throw "build failed with exit code $LASTEXITCODE" }
    & C:\python\python.exe -m build --wheel  --outdir dist
    if ($LASTEXITCODE -ne 0) { throw "build failed with exit code $LASTEXITCODE" }
    # test
    cd test
    & C:\python\python.exe -m pip install --only-binary ":all:" -r ..\test_requirements.txt --no-warn-script-location
    if ($LASTEXITCODE -ne 0) { throw "build failed with exit code $LASTEXITCODE" }
    & C:\python\python.exe -m pip install simplebloom --no-index -f ..\dist
    if ($LASTEXITCODE -ne 0) { throw "build failed with exit code $LASTEXITCODE" }
    & C:\python\python.exe -m pytest -vv
    if ($LASTEXITCODE -ne 0) { throw "test failed with exit code $LASTEXITCODE" }
    cd ..
    & choco uninstall python3 -y -r --no-progress
}
