@echo off
rem FeedFilter launcher: runs configure.ps1 with built-in Windows PowerShell.
rem -ExecutionPolicy Bypass applies to this one process only; no system setting is changed.
setlocal
rem Started from PowerShell 7, the inherited PSModulePath breaks 5.1 built-in modules; let 5.1 use its defaults.
set "PSModulePath="
set "FF_PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%FF_PS%" set "FF_PS=powershell.exe"
"%FF_PS%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0configure.ps1" %*
set "FF_RC=%ERRORLEVEL%"
echo.
echo configure finished with exit code %FF_RC%.
if not defined FF_NO_PAUSE pause
exit /b %FF_RC%
