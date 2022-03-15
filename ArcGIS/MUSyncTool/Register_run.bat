@echo off
echo Mike Urban Sync toll script...
echo Developed 7/2015 by Jakub Vajda and Oldøich Kolovrat, DHI a.s.
echo Requested installation of pyodbc, ArcGIS 10.1
title %~n0.bat 

set A_PATH=%~dp0
echo MUSyncTool directory %A_PATH%

IF EXIST C:\Windows\SysWOW64\wscript.exe set VBS_PATH=C:\Windows\SysWOW64\wscript.exe

set Log_PATH=%A_PATH%Logfile.log 
set SubLog_PATH=%A_PATH%Outputs\Logfile.log 
echo Logfile directory %Log_PATH%

SET LOG=1
set modulename=BAT
set levelname=DEBUG
set levelnameerr=ERROR
set levelnamechap=INFO
rem pause

:CurentDate
echo Current Month, Day, Year in Batch Files (Windows/DOS)
for /f "delims=" %%a in ('wmic OS Get localdatetime ^| find "."') do set xsukax=%%a

set YYYY=%xsukax:~0,4%
set MM=%xsukax:~4,2%
set DD=%xsukax:~6,2%

set CURDATE=%DD%-%MM%-%YYYY%
echo CURDATE %CURDATE%
rem pause

Del /Q "%A_PATH%Outputs\*.*"
IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; ; %modulename% ; %~n0 ; %levelnamechap% ; 2 ; Starting to check models registration >%Log_PATH%
IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; ; %modulename% ; %~n0 ; %levelname% ; 2 ; Deleting %A_PATH%Outputs\*.* >>%Log_PATH%
IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; ; %modulename% ; %~n0 ; %levelname% ; 2 ; Deleting/creating flags %A_PATH%Flag_Registration.txt >>%Log_PATH%
Del "%A_PATH%Flag_Registration.txt"
c:\ > "%A_PATH%Flag_Registration.txt"
rem pause


:Register
echo Register models
for %%f in ("%A_PATH%Inputs"\*.mdb) do (
    echo model: %%~nf.mdb
    REM copy %%f "%A_PATH%Temp\\%DD%.%MM%.%YYYY% %Time:~0,2%.%Time:~3,2%.%Time:~6,2%_%%~nf%%~xf"
    IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; ; %modulename% ; %~n0 ; %levelname% ; 2 ; * Starting Model Registration with model: %%~nf.mdb >>%Log_PATH%
	IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; ; %modulename% ; %~n0 ; %levelname% ; 2 ; * Starting Model Registration with model: %%~nf.mdb >%SubLog_PATH%
    Start /wait %VBS_PATH% %A_PATH%Register.vbs %A_PATH%Inputs\%%~nf.mdb %~n0.bat
    REM pause
)
rem pause

:End
IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; ; %modulename% ; %~n0 ; %levelname% ; 2 ; Deleting flags %A_PATH%Flag_Registration.txt >>%Log_PATH%

Del "%A_PATH%Flag_Registration.txt"
IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; ; %modulename% ; %~n0 ; %levelname% ; 2 ; Closing models registration >>%Log_PATH%
rem pause
exit


