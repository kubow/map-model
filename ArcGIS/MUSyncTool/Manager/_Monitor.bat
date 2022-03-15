@echo off
title %~n0.bat

SET A_PATH=%~dp0..\Active\
CD %A_PATH% 
REM echo %A_PATH%

REM PAUSE
echo Starting ArcGIS %A_PATH%Test.mxd
call "c:\Program Files (x86)\ArcGIS\Desktop10.1\bin\ArcMap.exe" "%A_PATH%Test.mxd"
REM PAUSE
exit