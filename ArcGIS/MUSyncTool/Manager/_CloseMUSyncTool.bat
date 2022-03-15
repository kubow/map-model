@echo off
echo Close MUOnlineWD...

SET A_PATH=%~dp0..\BatchRunner\
CD %A_PATH% 
ECHO %A_PATH%
pause

echo Closing %A_PATH%BatchRunner_MU-GIS_Update.exe
taskkill /f /im BatchRunner_MU-GIS_Update.exe > nul
rem pause

exit
