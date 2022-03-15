@echo off
echo Run Export Feature Class to table including subtype and domains  script...
echo Developed 7/2015 by Jakub Vajda and Oldřich Kolovrat, DHI a.s.
rem echo Requested installation of pyopenodbc 

set A_PATH=c:\DHI\RptTool
echo RptTool %A_PATH%

IF EXIST c:\Python27\ArcGIS10.1\python.exe (set PY_PATH=c:\Python27\ArcGIS10.1\python.exe) ELSE set PY_PATH=c:\Python25\python.exe
echo Python directory %PY_PATH%

set Log_PATH=%A_PATH%\Logfile.log 
echo Logfile directory %Log_PATH%

set GIS_PATH="c:"
echo GIS directory %GIS_PATH%

set GIS_FILE="PVK_VK.gdb"
echo GIS directory %GIS_FILE%

SET LOG=1
SET REF=1
choice /C 01 /T 5 /D 1 /M "Refresh GIS (0 - none / 1 - yes)?"
if errorlevel 1 SET REF=0
if errorlevel 2 SET REF=1
echo   Refresh GIS (0 - none / 1 - yes): %REF%
echo   Report to (0 - none / 1 - yes): %LOG% to %Log_Path%
rem pause

c:\ > "%A_PATH%\Run_Report.txt"

:CurentDate
echo Current Month, Day, Year in Batch Files (Windows/DOS)
for /f "delims=" %%a in ('wmic OS Get localdatetime ^| find "."') do set xsukax=%%a

set YYYY=%xsukax:~0,4%
set MM=%xsukax:~4,2%
set DD=%xsukax:~6,2%

set CURDATE=%DD%-%MM%-%YYYY%
echo CURDATE %CURDATE%
set modulename=BAT
set levelname=Msg
rem pause

:BackupLog
echo Archive Logfiles
for %%f in ("%A_PATH%"\*.log) do (
    set fname=%%~nf
    echo %%~nf
    move %%f "%A_PATH%"\Archive\%%~nf_%CURDATE%%%~xf
)

IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% - %modulename% - %levelname% - Start>>%Log_Path%
IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% - %modulename% - %levelname% - Bck Logfiles>>%Log_Path%
rem pause

:BackupReport
echo Archive Report

for %%f in ("%A_PATH%"\*.xls*) do (
    set fname=%%~nf
    echo %%~nf
    move %%f "%A_PATH%"\Archive\%%~nf_%CURDATE%%%~xf
)
IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% - %modulename% - %levelname% - Bck Report.xls* >>%Log_Path%
rem pause

echo Archive Report.mdb

for %%f in ("%A_PATH%"\*.mdb) do (
    set fname=%%~nf
    echo %%~nf
    move %%f "%A_PATH%"\Archive\%%~nf_%CURDATE%%%~xf
)
IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% - %modulename% - %levelname% - Bck Report.mdb >>%Log_Path%
rem pause

:Delete
Del "%A_PATH%\*.xls*"
IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% - %modulename% - %levelname% - Delete previous report >>%Log_Path%
rem pause

:GIS
echo Refresh GIS
IF %REF% == 1 (
IF EXIST %A_PATH%\%GIS_FILE% (rmdir /Q /S %A_PATH%\%GIS_FILE%) ELSE IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% - %modulename% - %levelname% - Target GIS not found>>%Log_Path%
xcopy %GIS_PATH%\%GIS_FILE% %A_PATH%\%GIS_FILE% /i
IF EXIST %A_PATH%\%GIS_FILE% (IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% - %modulename% - %levelname% - Target GIS updated>>%Log_Path%) ELSE IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% - %modulename% - Err - Target GIS not found>>%Log_Path%
) ELSE IF %REF% == 0 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% - %modulename% - %levelname% - Skipping refresh GIS>>%Log_Path%
rem pause

:Python
echo Run Python procedure
IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% - %modulename% - %levelname% - Python Start>>%Log_Path%

IF NOT EXIST %PY_PATH% IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% - %modulename% - %levelname% - Correct PY path %PY_PATH%  >>%Log_Path%
IF NOT EXIST %PY_PATH% GOTO End

IF NOT EXIST %A_PATH%\*.py IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% - %modulename% - %levelname% - Error missing Script .PY >>%Log_Path%
IF NOT EXIST %A_PATH%\*.py GOTO End

Start /wait %PY_PATH% %A_PATH%\GDB2MDBTableInclDomains.py

IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% - %modulename% - %levelname% - Call Python Script Finished>>%Log_Path%
IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% - %modulename% - %levelname% - Call VBS postprocess Start>>%Log_Path%
Start /wait %A_PATH%\Report.vbs
IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% - %modulename% - %levelname% - Call VBS postprocess Finished>>%Log_Path%
rem pause

:Compact
call "%A_PATH%\Report.mdb" /compact
IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% - %modulename% - %levelname% - Compact and repair report.mdb done>>%Log_Path%
rem pause

:Templates
echo Copy new templates
copy "%A_PATH%\Templates\*.xls*" "%A_PATH%\*.xls*"
IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% - %modulename% - %levelname% - Copy new templates>>%Log_Path%
rem pause

:BackupDel
echo Delete older files then D (Days) in Backup dir %A_PATH%\Archive
forfiles -p "%A_PATH%\Archive" -s -m *.* /D -60 /C "cmd /c del @path"
IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% - %modulename% - %levelname% - Archive old deleted  >>%Log_Path%
rem pause

:End
Del "%A_PATH%\Run_report.txt"
IF %LOG% == 1 echo %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% - %modulename% - %levelname% - Finished >>%Log_Path%
rem pause
exit
