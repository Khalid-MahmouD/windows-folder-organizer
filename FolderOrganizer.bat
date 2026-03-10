@echo off
set SCRIPT=%~dp0FolderOrganizer.ps1
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%SCRIPT%"
