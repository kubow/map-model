@ECHO off
ECHO Mike Urban Sync tool script...
ECHO Developed 2/2016 by Jakub Vajda and Oldřich Kolovrat, DHI a.s.
ECHO Requested installation of ArcGIS 10.1 (ESRI) and pyodbc 
title %~n0.bat

SET A_PATH=%~dp0
ECHO MUSyncTool directory %A_PATH%

SET Log_PATH=%A_PATH%Logfile.log 
SET SubLog_PATH=%A_PATH%Outputs\Logfile.log 
ECHO Logfile directory %Log_PATH%
ECHO SubLogfile directory %SubLog_PATH%

SET LOG=1
SET modulename=BAT
SET levelname=DEBUG
SET levelnamewar=WARNING
SET levelnameerr=ERROR
SET levelnamechap=INFO
REM PAUSE

:CurentDate
ECHO Current Month, Day, Year in Batch Files (Windows/DOS)
FOR /f "delims=" %%a IN ('wmic OS Get localdatetime ^| find "."') DO SET xsukax=%%a

SET YYYY=%xsukax:~0,4%
SET MM=%xsukax:~4,2%
SET DD=%xsukax:~6,2%

SET CURDATE=%DD%-%MM%-%YYYY%
ECHO CURDATE %CURDATE%
REM PAUSE

:ScriptStart
IF EXIST c:\Python27\ArcGIS10.1\python.exe SET PY_PATH=c:\Python27\ArcGIS10.1\python.exe
IF EXIST c:\Python27\ArcGIS10.1\python.exe SET PY_FLD=c:\Python27\ArcGIS10.1\
IF EXIST c:\Python27\ArcGIS10.3\python.exe SET PY_PATH=c:\Python27\ArcGIS10.3\python.exe
IF EXIST c:\Python27\ArcGIS10.3\python.exe SET PY_FLD=c:\Python27\ArcGIS10.3\

IF EXIST C:\Windows\SysWOW64\wscript.exe SET VBS_PATH=C:\Windows\SysWOW64\wscript.exe
IF NOT EXIST C:\Windows\SysWOW64\wscript.exe SET VBS_PATH=C:\Windows\System32\wscript.exe 

DEL /Q "%A_PATH%Outputs\*.*"
RD %A_PATH%Temp /s/q
MD %A_PATH%Temp
IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; ; %modulename% ; %~n0 ; %levelnamechap% ; 0 ;  * * * Starting process of comparison >%Log_PATH%
IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; ; %modulename% ; %~n0 ; %levelname% ; 0 ; Deleting %A_PATH%Outputs\*.* >>%Log_PATH%
IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; ; %modulename% ; %~n0 ; %levelname% ; 0 ; Deleting/creating %A_PATH%Temp\*.* >>%Log_PATH%
IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; ; %modulename% ; %~n0 ; %levelname% ; 0 ; Deleting/creating flags %A_PATH%Flag_Comparison.txt >>%Log_PATH%
Del "%A_PATH%Flag_Comparison.txt"
c:\ > "%A_PATH%Flag_Comparison.txt"

IF [%PY_PATH%]==[] (
	ECHO not found python path
	IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; ; %modulename% ; %~n0 ; %levelname% ; 0 ; Python path not found (using different version of ArcGIS?) >>%Log_PATH%
	REM GOTO END
)
IF NOT EXIST %PY_FLD%\Lib\site-packages\pyodbc*.* (
	ECHO not found pyodbc
	IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; ; %modulename% ; %~n0 ; %levelname% ; 0 ; PyODBC instalaltion not found - please install first >>%Log_PATH%
	REM GOTO END
)
ECHO Python directory %PY_PATH%
REM PAUSE

:Comparison_Procedure
ECHO Run comparision procedure
FOR %%f IN ("%A_PATH%Inputs"\*.mdb) DO (
	ECHO model: %%~nf.mdb
	:Register
	ECHO -check model registration: %%~nf.mdb
	IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 2 ; * Checking model registration with model: %%~nf.mdb >>%Log_PATH%
	IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 2 ; * Checking model registration with model: %%~nf.mdb >%SubLog_PATH%
	Start /wait %VBS_PATH% %A_PATH%Register.vbs %A_PATH%Inputs\%%~nf.mdb %~n0.bat
	IF EXIST %A_PATH%Outputs\Selection.txt ( 
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 2 ; Model: %%~nf.mdb selected to run, processing ... >>%Log_PATH% 
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 2 ; Model: %%~nf.mdb selected to run, processing ... >>%SubLog_PATH% 
	) ELSE ( 
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelnamewar% ; 2 ; Model: %%~nf.mdb not selected to run, skipping ... >>%Log_PATH% 
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelnamewar% ; 2 ; Model: %%~nf.mdb not selected to run, skipping ... >>%SubLog_PATH% 
	)
	REM PAUSE
	
	:Transfer
	IF EXIST %A_PATH%Outputs\Selection.txt ( 
		ECHO -transfer to Outputs ; copy %A_PATH%Inputs\%%~nf.mdb %A_PATH%Outputs\Model.mdb
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelnamechap% ; 3 ; Checking and data completation >>%Log_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelnamechap% ; 3 ; Checking and data completation >>%SubLog_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 3 ; Model: %%~nf.mdb copying to %A_PATH%Oututs\Model.mdb >>%Log_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 3 ; Model: %%~nf.mdb copying to %A_PATH%Oututs\Model.mdb >>%SubLog_PATH%
		copy %A_PATH%Inputs\%%~nf.mdb %A_PATH%Outputs\Model.mdb
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 3 ; Model: %%~nf.mdb copying to %A_PATH%Oututs\Model_orig.mdb >>%Log_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 3 ; Model: %%~nf.mdb copying to %A_PATH%Oututs\Model_orig.mdb >>%SubLog_PATH%
		copy %A_PATH%Inputs\%%~nf.mdb %A_PATH%Outputs\Model_orig.mdb
		IF EXIST %A_PATH%Outputs\Model.mdb IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 3 ; Founded %A_PATH%Outputs\Model.mdb >>%Log_PATH%
		IF EXIST %A_PATH%Outputs\Model.mdb IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 3 ; Founded %A_PATH%Outputs\Model.mdb >>%SubLog_PATH%
		IF NOT EXIST %A_PATH%Outputs\Model.mdb IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelnameerr% ; 3 ; Missing %A_PATH%Outputs\Model.mdb >>%Log_PATH%
		IF NOT EXIST %A_PATH%Outputs\Model.mdb IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelnameerr% ; 3 ; Missing %A_PATH%Outputs\Model.mdb >>%SubLog_PATH%
	)
	REM PAUSE
	
	:Templates
	IF EXIST %A_PATH%Outputs\Selection.txt ( 
		ECHO -copy new templates
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 3 ; Copying new templates to %A_PATH%Outputs dir >>%Log_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 3 ; Copying new templates to %A_PATH%Outputs dir >>%SubLog_PATH%
		copy "%A_PATH%Templates\*.*" "%A_PATH%Outputs\*.*"
		IF EXIST %A_PATH%Outputs\Comparison.mdb IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 3 ; Founded %A_PATH%Outputs\Comparison.mdb >>%Log_PATH%
		IF EXIST %A_PATH%Outputs\Comparison.mdb IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 3 ; Founded %A_PATH%Outputs\Comparison.mdb >>%SubLog_PATH%
		IF NOT EXIST %A_PATH%Outputs\Comparison.mdb IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelnameerr% ; 3 ; Missing %A_PATH%Outputs\Comparison.mdb >>%Log_PATH%
		IF NOT EXIST %A_PATH%Outputs\Comparison.mdb IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelnameerr% ; 3 ; Missing %A_PATH%Outputs\Comparison.mdb >>%SubLog_PATH%
		rem IF NOT EXIST %A_PATH%Outputs\Comparison.mdb GOTO End !!!
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 3 ; Starting MASTER preprocess based on GIS >>%Log_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 3 ; Starting MASTER preprocess based on GIS >>%SubLog_PATH%
	)
	REM PAUSE

	:Python
	IF EXIST %A_PATH%Outputs\Selection.txt (
		ECHO -run Python procedure with model: %%~nf.mdb
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelnamechap% ; 4 ; Import 1: MASTER >>%Log_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelnamechap% ; 4 ; Import 1: MASTER >>%SubLog_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 4 ; Starting Pythons scripts >>%Log_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 4 ; Starting Pythons scripts >>%SubLog_PATH%
		IF NOT EXIST %PY_PATH% IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelnameerr% ; 4 ; Correct PY path %PY_PATH%  >>%Log_PATH%
		IF NOT EXIST %PY_PATH% IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelnameerr% ; 4 ; Correct PY path %PY_PATH%  >>%SubLog_PATH%
		IF NOT EXIST %A_PATH%*.py IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelnameerr% ; 4 ; Missing script .PY >>%Log_PATH%
		IF NOT EXIST %A_PATH%*.py IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelnameerr% ; 4 ; Missing script .PY >>%SubLog_PATH%
		
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 4 ; Starting ModelPrepare.py >>%Log_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 4 ; Starting ModelPrepare.py >>%SubLog_PATH%
		Start /wait %PY_PATH% %A_PATH%ModelPrepare.py
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 4 ; Starting DataExport.py >>%Log_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 4 ; Starting DataExport.py >>%SubLog_PATH%
		Start /wait %PY_PATH% %A_PATH%DataExport.py
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 4 ; Starting PointAssignment.py >>%Log_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 4 ; Starting PointAssignment.py >>%SubLog_PATH%
		Start /wait %PY_PATH% %A_PATH%PointAssignment.py %~n0.bat
		
		IF NOT EXIST %A_PATH%Outputs\Master.mdb IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelnameerr% ; 4 ; Missing %A_PATH%Outputs\Master.mdb >>%Log_PATH%
		IF NOT EXIST %A_PATH%Outputs\Master.mdb IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelnameerr% ; 4 ; Missing %A_PATH%Outputs\Master.mdb >>%SubLog_PATH%
		REM IF NOT EXIST %A_PATH%Outputs\Master.mdb GOTO End !!!!!!!!!!
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 4 ; Finishing Python scripts >>%Log_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 4 ; Finishing Python scripts >>%SubLog_PATH%
		ECHO -finished Python procedure
	)
	REM PAUSE
	
	:Comparison
	IF EXIST %A_PATH%Outputs\Selection.txt (
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelnamechap% ; 5 ; Model and GIS comparison >>%Log_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelnamechap% ; 5 ; Model and GIS comparison >>%SubLog_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 5 ; Starting comparison procedure %A_PATH%Comparison_report.vbs >>%Log_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 5 ; Starting comparison procedure %A_PATH%Comparison_report.vbs >>%SubLog_PATH%
		IF NOT EXIST %A_PATH%Comparison_report.vbs IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelnameerr% ; 5 ; Missing %A_PATH%Comparison_report.vbs >>%Log_PATH%
		IF NOT EXIST %A_PATH%Comparison_report.vbs IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelnameerr% ; 5 ; Missing %A_PATH%Comparison_report.vbs >>%SubLog_PATH%
		REM IF NOT EXIST %A_PATH%Comparison_report.vbs GOTO End !!!!!
		Start /wait %A_PATH%Comparison_report.vbs
    
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 5 ; Model: %%~nf.mdb copying to %A_PATH%Oututs\Model_comparison.mdb >>%Log_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 5 ; Model: %%~nf.mdb copying to %A_PATH%Oututs\Model_comparison.mdb >>%SubLog_PATH%
    copy %A_PATH%Outputs\Model.mdb %A_PATH%Outputs\Model_comparison.mdb
	)
	REM PAUSE

	:Compact
	IF EXIST %A_PATH%Outputs\Selection.txt (
		ECHO -compacting database Master.mdb
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 5 ; Compact and repairing %A_PATH%Outputs\Master.mdb >>%Log_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 5 ; Compact and repairing %A_PATH%Outputs\Master.mdb >>%SubLog_PATH%
		IF EXIST %A_PATH%Outputs\Master.mdb IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 5 ; Founded %A_PATH%Outputs\Master.mdb >>%Log_PATH%
		IF EXIST %A_PATH%Outputs\Master.mdb IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 5 ; Founded %A_PATH%Outputs\Master.mdb >>%SubLog_PATH%
		ECHO +++compact disabled
		REM Call "%A_PATH%Outputs\Master.mdb" /compact
	)
	REM PAUSE 

	:Sendemail_comparison
	IF EXIST %A_PATH%Outputs\Selection.txt (
		ECHO -sending email with report details
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelnamechap% ; 6 ; Starting send email comparison >>%Log_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelnamechap% ; 6 ; Starting send email comparison >>%SubLog_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 6 ; Founded comparison report %A_PATH%Outputs\wd_Rep_Control.pdf >>%Log_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 6 ; Founded comparison report %A_PATH%Outputs\wd_Rep_Control.pdf >>%SubLog_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 6 ; Founded comparison report %A_PATH%Outputs\wd_Rep_Comparison.pdf >>%Log_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 6 ; Founded comparison report %A_PATH%Outputs\wd_Rep_Comparison.pdf >>%SubLog_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 6 ; Founded comparison report %A_PATH%Outputs\wd_Rep_ModelFlags.pdf >>%Log_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 6 ; Founded comparison report %A_PATH%Outputs\wd_Rep_ModelFlags.pdf >>%SubLog_PATH%
		
		Call %A_PATH%Comparison_sendemail.bat
		
	)
	REM PAUSE

	:Temp_IN
	IF EXIST %A_PATH%Outputs\Selection.txt (
		ECHO -transfer to Temp directory ; DOne with VB Script ; additionally clear Selection.txt
		DEL %A_PATH%Outputs\Selection.txt
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelnamechap% ; 6 ; Begin transfer Outputs to Temp directory >>%Log_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelnamechap% ; 6 ; Begin transfer Outputs to Temp directory >>%SubLog_PATH%
		IF NOT EXIST %A_PATH%CopyToTemp.vbs IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelnameerr% ; 6 ; Missing %A_PATH%Comparison_report.vbs >>%Log_PATH%
		IF NOT EXIST %A_PATH%CopyToTemp.vbs IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelnameerr% ; 6 ; Missing %A_PATH%Comparison_report.vbs >>%SubLog_PATH%
    
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 6 ; Started transfer Outputs to Temp directory >>%SubLog_PATH%
    
    
		REM IF NOT EXIST %A_PATH%CopyToTemp.vbs GOTO End !!!!
		REM PAUSE
		Start /wait %VBS_PATH% %A_PATH%CopyToTemp.vbs
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 6 ; Finished transfer Outputs to Temp directory >>%Log_PATH%
		REM TIMEOUT 10
		REM IF EXIST %A_PATH%TEMP\ DEL /Q "%A_PATH%Outputs\*.*"
		REM IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 5 ; Finished deleting %A_PATH%Outputs\*.* >>%Log_PATH%
		REM PAUSE
    
		REM IF NOT EXIST %A_PATH%Temp\%%~nf\ md %A_PATH%Temp\%%~nf\
		REM IF EXIST %A_PATH%Temp\%%~nf copy %A_PATH%Outputs\*.* %A_PATH%Temp\%%~nf_c\*.* /Y
		REM IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 2 ; Model: %A_PATH%Outputs\Model.mdb copying to %A_PATH%Temp\%%~nf\Model.mdb >>%Log_PATH%
		REM IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 1 ; Copying Model.mdb to Outputs dir>>%Log_PATH%
		REM IF EXIST %A_PATH%Temp\%%~nf\Model.mdb IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelname% ; 1 ; Founded %A_PATH%Temp\%%~nf\Model.mdb >>%Log_PATH%
		REM IF NOT EXIST %A_PATH%Temp\%%~nf\Model.mdb IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%~nf ; %modulename% ; %~n0 ; %levelnameerr% ; 1 ; Missing %A_PATH%Temp\%%~nf\Model.mdb >>%Log_PATH%
		REM IF NOT EXIST %A_PATH%Outputs\Model.mdb GOTO End !!!!!!!!!!!!!!!!!!!!!!!!!!!!
	)
	REM PAUSE
)

:End
IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; ; %modulename% ; %~n0 ; %levelname% ; 0 ; Deleting flags %A_PATH%Flag_Comparison.txt >>%Log_PATH%

DEL "%A_PATH%Flag_Comparison.txt"
IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; ; %modulename% ; %~n0 ; %levelname% ; 0 ; Closing script >>%Log_PATH%
REM PAUSE
REM XIT


