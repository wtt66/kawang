@echo off
setlocal EnableExtensions

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "WORKSPACE_DIR=%%~fI"

set "SERVICE_NAME=Admin dev"
set "PORT=5174"
set "POWERSHELL_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
set "HELPER_SCRIPT=%WORKSPACE_DIR%\scripts\dev\Stop-PortListeners.ps1"

if not exist "%POWERSHELL_EXE%" (
  echo PowerShell not found at "%POWERSHELL_EXE%".
  exit /b 1
)

if not exist "%HELPER_SCRIPT%" (
  echo Helper script not found at "%HELPER_SCRIPT%".
  exit /b 1
)

call "%POWERSHELL_EXE%" -NoProfile -ExecutionPolicy Bypass -File "%HELPER_SCRIPT%" -ServiceName "%SERVICE_NAME%" -Port %PORT%
exit /b %errorlevel%
