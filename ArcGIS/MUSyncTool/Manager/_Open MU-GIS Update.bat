@echo off
echo Run MU-GIS Update...

SET A_PATH=%~dp0..\BatchRunner\
CD %A_PATH% 
ECHO %A_PATH%

echo Start %A_PATH%BatchRunner_MU-GIS_Update.exe
start %A_PATH%BatchRunner_MU-GIS_Update.exe > nul
rem pause

exit
