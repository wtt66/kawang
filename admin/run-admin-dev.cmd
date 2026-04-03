@echo off
setlocal EnableExtensions

set "SCRIPT_DIR=%~dp0"
set "WORKING_DIR=%SCRIPT_DIR:~0,-1%"
for %%I in ("%SCRIPT_DIR%..") do set "WORKSPACE_DIR=%%~fI"

set "SERVICE_NAME=Admin dev"
set "PORT=5174"
set "URL=http://127.0.0.1:%PORT%"
set "LOG_FILE=%WORKSPACE_DIR%\.dev-logs\admin-dev.log"
set "POWERSHELL_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
set "HELPER_SCRIPT=%WORKSPACE_DIR%\scripts\dev\Invoke-LoggedCommand.ps1"

if not defined NODE_HOME set "NODE_HOME=E:\IDEA\Node22"
set "VITE_BIN=%SCRIPT_DIR%node_modules\vite\bin\vite.js"

if not exist "%NODE_HOME%\node.exe" (
  echo Node.js not found at "%NODE_HOME%".
  exit /b 1
)

if not exist "%POWERSHELL_EXE%" (
  echo PowerShell not found at "%POWERSHELL_EXE%".
  exit /b 1
)

if not exist "%HELPER_SCRIPT%" (
  echo Helper script not found at "%HELPER_SCRIPT%".
  exit /b 1
)

set "PATH=%NODE_HOME%;%PATH%"
cd /d "%WORKING_DIR%"

if not exist "node_modules" (
  echo Installing admin dependencies...
  call "%NODE_HOME%\npm.cmd" install
  if errorlevel 1 exit /b %errorlevel%
)

if not exist "%VITE_BIN%" (
  echo Repairing admin dependencies...
  call "%NODE_HOME%\npm.cmd" install
  if errorlevel 1 exit /b %errorlevel%
)

if not exist "%VITE_BIN%" (
  echo Vite entrypoint not found at "%VITE_BIN%".
  exit /b 1
)

set "DEV_COMMAND_LINE="%NODE_HOME%\node.exe" "%VITE_BIN%" --host 127.0.0.1 --port %PORT%"

call "%POWERSHELL_EXE%" -NoProfile -ExecutionPolicy Bypass -File "%HELPER_SCRIPT%" -ServiceName "%SERVICE_NAME%" -WorkingDirectory "%WORKING_DIR%" -LogFile "%LOG_FILE%" -Url "%URL%" -Port %PORT%
exit /b %errorlevel%
