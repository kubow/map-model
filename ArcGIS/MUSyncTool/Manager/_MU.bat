@echo off
title %~n0.bat

SET A_PATH=%~dp0..\Active\
CD %A_PATH% 
ECHO %A_PATH%

REM PAUSE
echo Starting MIKE URBAN %A_PATH%Model.mdb
call "C:\Program Files (x86)\DHI\2014\Bin\MU.exe" "%A_PATH%Model.mdb"
REM PAUSE
exit