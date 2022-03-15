@echo on
echo Mike Urban Sync toll script (part update)...
echo Developed 2/2016 by Jakub Vajda and Oldøich Kolovrat, DHI a.s.
echo Requested installation of Mike Urban v.2014 (DHI), ArcGIS 10.1 (ESRI), EpanetWrapper (DHI)
title %~n0.bat

set A_PATH=%~dp0
echo MUSyncTool directory %A_PATH%

set Log_PATH=%A_PATH%Outputs\Logfile.log 
echo Logfile directory %Log_PATH%

SET LOG=1
set modulename=BAT
set levelname=DEBUG
set levelnameerr=ERROR
set levelnamechap=INFO
rem pause

Del "%A_PATH%Flag_Distribution.txt"
c:\ > "%A_PATH%Flag_Distribution.txt"

:CurentDate
echo Current Month, Day, Year in Batch Files (Windows/DOS)
for /f "delims=" %%a in ('wmic OS Get localdatetime ^| find "."') do set xsukax=%%a

set YYYY=%xsukax:~0,4%
set MM=%xsukax:~4,2%
set DD=%xsukax:~6,2%

set CURDATE=%DD%-%MM%-%YYYY%
echo CURDATE %CURDATE%
rem pause

IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %modulename% ; %~n0 ; %levelname% ; 0 ; Starting Distribution >>%Log_Path%
IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %modulename% ; %~n0 ; %levelname% ; 0 ; Deleting/creating flags %A_PATH%Flag_Distribution.txt >>%Log_Path%


:Sendemail_update
IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %modulename% ; %~n0 ; %levelnamechap% ; 8 ; Epanet report %A_PATH%Outputs\Model.sum >>%Log_Path%
IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %modulename% ; %~n0 ; %levelname% ; 8 ; Sending email from Epanet calculation %A_PATH%Outputs\Model.sum >>%Log_Path%

echo Send update model report by mail
Call %A_PATH%Update_sendemail.bat
rem pause

:Archive_Temp
IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %modulename% ; %~n0 ; %levelnamechap% ; 9 ; Outputs archivation >>%Log_Path%
IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %modulename% ; %~n0 ; %levelname% ; 9 ; Starting outputs archivation A_PATH%Archive\*.* >>%Log_Path%

REM echo Archive Outputs
REM for %%f in ("%A_PATH%Temp"\*.*) do (
REM     set fname=%%~nf
REM     echo %%~nf
REM     copy %%f "%A_PATH%Temp\\%DD%.%MM%.%YYYY% %Time:~0,2%.%Time:~3,2%.%Time:~6,2%_%%~nf%%~xf"
REM )
IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %modulename% ; %~n0 ; %levelname% ; 9 ; Finished outputs archivation A_PATH%Temp\*.* >>%Log_Path%
rem pause
rem move
rem pause

:BackupDel
IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %modulename% ; %~n0 ; %levelname% ; 9 ; Archive maintenance A_PATH%Archive >>%Log_Path%

echo Delete older files then D (Days) in Backup dir %A_PATH%Archive
forfiles -p "%A_PATH%Archive" -s -m *.* /D -60 /C "cmd /c del @path"
IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %modulename% ; %~n0 ; %levelname% ; 9 ; Deleted old data in A_PATH%Archive\*.* >>%Log_Path%
rem pause

:End
IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %modulename% ; %~n0 ; %levelname% ; 0 ; Deleting flags %A_PATH%Flag_Update.txt >>%Log_Path%

Del "%A_PATH%Flag_Distribution.txt"
IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %modulename% ; %~n0 ; %levelname% ; 0 ; Closing Distribution >>%Log_Path%
rem pause
exit


