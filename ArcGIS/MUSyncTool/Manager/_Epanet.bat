@echo off
title %~n0.bat

SET A_PATH=%~dp0..\Active\
CD %A_PATH% 
REM echo %A_PATH%

REM PAUSE
echo Starting Epanet %A_PATH%Model.inp
call "C:\Program Files (x86)\EPANET2\Epanet2w.exe" "%A_PATH%Model.inp"
REM PAUSE
exit