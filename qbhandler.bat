@echo off
set "TORRENT_FILE=%~1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\km\git\qbhandler\qbhandler.ps1" "%TORRENT_FILE%"
