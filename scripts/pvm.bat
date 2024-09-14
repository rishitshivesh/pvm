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

set PVM_HOME=%USERPROFILE%\.pvm

:: Check if PVM_HOME is already in the PATH
echo %PATH% | findstr /I /C:"%PVM_HOME%" >nul
if %ERRORLEVEL%==0 (
    echo PVM_HOME is already in PATH.
) else (
    :: Temporarily add PVM_HOME to the current session's PATH
    set PATH=%PVM_HOME%\bin;%PATH%

    :: Permanently add PVM_HOME to the User's PATH
    setx PATH "%PVM_HOME%\bin;%PATH%" >nul
    echo PVM_HOME has been added to PATH permanently.
)