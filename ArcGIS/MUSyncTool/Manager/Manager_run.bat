@echo off
echo Starting Online Manager ...
title %~n0.bat
SET A_PATH=%~dp0
call "c:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft PowerPoint Viewer .lnk" "%A_PATH%\Manager.ppsm"