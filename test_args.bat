@echo off
set "TMPPS=%TEMP%\test_args.ps1"
echo param([string]$AppDir); Write-Host "AppDir is: '$AppDir'" > "%TMPPS%"
powershell -NoProfile -File "%TMPPS%" "%~dp0."
powershell -NoProfile -File "%TMPPS%" "%~dp0"
del "%TMPPS%"
