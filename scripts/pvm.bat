set PVM_HOME=%USERPROFILE%\.pvm

if not exist "%PVM_HOME%\versions" (
    mkdir "%PVM_HOME%\versions"
)

:install
set PYTHON_VERSION=%1
curl -o "%PVM_HOME%\python-%PYTHON_VERSION%.exe" "https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-amd64.exe"
start /wait "" "%PVM_HOME%\python-%PYTHON_VERSION%.exe" /quiet InstallAllUsers=1 PrependPath=1
del "%PVM_HOME%\python-%PYTHON_VERSION%.exe"
goto :eof
