@ECHO off
ECHO Mike Urban Sync tool script ...
ECHO Developed 2/2016 by Jakub Vajda and Oldøich Kolovrat, DHI a.s.
ECHO Requested installation of Mike Urban v.2014 (DHI), ArcGIS 10.1 (ESRI), EpanetWrapper (DHI)
title %~n0.bat

SET A_PATH=%~dp0
ECHO MUSyncTool directory %A_PATH%

SET Log_PATH=%A_PATH%Logfile.log
SET SubLog_PATH=%A_PATH%Outputs\Logfile.log 
SET SubUpdateLog_PATH=%A_PATH%Outputs\Update.log 
ECHO Main logfile directory %Log_PATH%
ECHO Logfile directory %SubLog_PATH%
ECHO Update logfile directory %SubUpdateLog_PATH%

SET LOG=1
SET modulename=BAT
SET levelname=DEBUG
SET levelnamewar=WARNING
SET levelnameerr=ERROR
SET levelnamechap=INFO
REM PAUSE

:CurentDate
ECHO Current Month, Day, Year in Batch Files (Windows/DOS)
for /f "delims=" %%a IN ('wmic OS Get localdatetime ^| find "."') do SET xsukax=%%a

SET YYYY=%xsukax:~0,4%
SET MM=%xsukax:~4,2%
SET DD=%xsukax:~6,2%

SET CURDATE=%DD%-%MM%-%YYYY%
ECHO CURDATE %CURDATE%
REM PAUSE

:ScriptStart
IF EXIST c:\PROGRA~2\DHI\2014\ SET MU_PATH=c:\PROGRA~2\DHI\2014\
IF EXIST c:\PROGRA~2\DHI\2016\ SET MU_PATH=c:\PROGRA~2\DHI\2016\

IF EXIST c:\Python27\ArcGIS10.1\python.exe SET PY_PATH=c:\Python27\ArcGIS10.1\python.exe
IF EXIST c:\Python27\ArcGIS10.3\python.exe SET PY_PATH=c:\Python27\ArcGIS10.3\python.exe

IF EXIST C:\Windows\SysWOW64\wscript.exe SET VBS_PATH=C:\Windows\SysWOW64\wscript.exe
IF NOT EXIST C:\Windows\SysWOW64\wscript.exe SET VBS_PATH=C:\Windows\System32\wscript.exe 

DEL /Q "%A_PATH%Outputs\*.*"
IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; ; %modulename% ; %~n0 ; %levelname% ; 0 ; * * * Starting process of update >>%Log_Path%
IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; ; %modulename% ; %~n0 ; %levelname% ; 0 ; Deleting %A_PATH%Outputs\*.* >>%Log_PATH%
IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; ; %modulename% ; %~n0 ; %levelname% ; 0 ; DELeting/creating flags %A_PATH%Flag_Update.txt >>%Log_Path%
DEL "%A_PATH%Flag_Update.txt"
c:\ > "%A_PATH%Flag_Update.txt"

IF [%PY_PATH%]==[] (
	ECHO not found python path
	IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; ; %modulename% ; %~n0 ; %levelname% ; 0 ; Python path not found (using different version of ArcGIS?) >>%Log_PATH%
	REM GOTO END
)
IF [%MU_PATH%]==[] (
	ECHO not found MU path
	IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; ; %modulename% ; %~n0 ; %levelname% ; 0 ; MIKE URBAN instalation path not found >>%Log_PATH%
	REM GOTO END
)
ECHO MIKE URBAN directory %MU_PATH%

:Update_Procedure
ECHO Run update procedure - start iterating in %A_PATH%Temp directory 
FOR /f "tokens=*" %%G IN ('dir /b /o:n /ad %A_PATH%Temp') do (
	ECHO -check model registration: Model.mdb in directory %%G
	IF EXIST "%A_PATH%Temp\%%G\Selection.txt" DEL "%A_PATH%Temp\%%G\Selection.txt"
	Start /wait %VBS_PATH% %A_PATH%Register.vbs "%A_PATH%Temp\%%G\Model.mdb" %~n0.bat
	IF EXIST %A_PATH%Temp\%%G\Selection.txt ( 
		SETLOCAL ENABLEDELAYEDEXPANSION
		SET inner=%%G 
		SET mode=!inner:~0,2!
		SET argument=!inner:~-2,-1!
		SET model=!inner:~0,-4!
		ECHO model name: !model!, mode is !mode!, argument is !argument!, last run procedure !inner:~-3,-2! - %%G
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 2 ; * Checking model registration with model: Model.mdb >>%Log_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 2 ; * Checking model registration with model: Model.mdb >%SubLog_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 2 ; Model: Model.mdb selected to run, processing ... >>%Log_PATH% 
		REM IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %modulename% ; %~n0 ; %levelname% ; 2 ; Model: Model.mdb selected to run, processing ... >>%SubLog_PATH% 
	) 
	IF NOT EXIST %A_PATH%Temp\%%G\Selection.txt ( 
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%G ; %modulename% ; %~n0 ; %levelname% ; 2 ; * Checking model registration with model: Model.mdb >>%Log_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%G ; %modulename% ; %~n0 ; %levelname% ; 2 ; * Checking model registration with model: Model.mdb >%SubLog_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %%G ; %modulename% ; %~n0 ; %levelnamewar% ; 2 ; Model: Model.mdb not selected to run or it was already updated, skipping ... >>%Log_PATH% 
		REM IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %modulename% ; %~n0 ; %levelnamewar% ; 2 ; Model: Model.mdb not selected to run, skipping ... >>%SubLog_PATH% 
	)
	ENDLOCAL
	PAUSE
	
	:Outputs
	IF EXIST %A_PATH%Temp\%%G\Selection.txt (
		REM ----- need to delete %A_PATH%Temp\%%G\ after proper process
		echo -copying files to Outputs
		COPY %A_PATH%Temp\%%G\*.* %A_PATH%Outputs
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelnamechap% ; 7 ; Model: Copied all files from %A_PATH%Temp\%%G to %A_PATH%Outputs ... >>%Log_PATH%
		REM IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %modulename% ; %~n0 ; %levelnamechap% ; 7 ; Model: Backed up %A_PATH%Outputs\Model.mdb as Model_comparison.mdb ... >>%Log_PATH%
	)
	REM ----- at this moment we can start with appending to sublogfile2 - logfile in Outputs folder
	REM PAUSE
	
	:PrepXML
	IF EXIST %A_PATH%Outputs\Selection.txt (
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Starting path correction %A_PATH%PrepareXML.vbs >>%Log_Path%
		REM for /f "delims=" %%x in (%A_PATH%Outputs\ModelAttributes\mode.txt) do set mode=%%x
		IF NOT EXIST %A_PATH%PrepareXML.vbs IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelnameerr% ; 5 ; Missing %A_PATH%PrepareXML.vbs >>%Log_Path%
		REM IF NOT EXIST %A_PATH%PrepareXML.vbs GOTO End !!!
		IF NOT EXIST %A_PATH%Outputs\!mode!_import.xml IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelnameerr% ; 5 ; Missing %A_PATH%Outputs\!mode!_import.xml >>%Log_Path%
		REM IF NOT EXIST %A_PATH%Outputs\wd_import.xml GOTO End !!!
		Start /wait %A_PATH%PrepareXML.vbs "%A_PATH%Outputs\!mode!_import.xml"
		IF NOT EXIST %A_PATH%Outputs\!mode!_import.xml IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelnameerr% ; 5 ; Missing %A_PATH%Outputs\!mode!_import.xml >>%Log_Path%
		REM IF NOT EXIST %A_PATH%Outputs\wd_import.xml GOTO End !!!
		ECHO prepared XML file for mode !mode!
	)
	REM PAUSE
	
	:Import
	IF EXIST %A_PATH%Outputs\Selection.txt (
		ECHO Import data into MIKE URBAN script >%SubUpdateLog_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelnamechap% ; 7 ; Starting Import 2: Model update >>%Log_Path%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Creating %SubLog_PATH% >>%Log_Path%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Starting update model based on MASTER >>%Log_Path%
		IF NOT EXIST %A_PATH%Outputs\Master.mdb IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelnameerr% ; 7 ; Missing %A_PATH%Outputs\Master.mdb >>%Log_Path%
		REM IF NOT EXIST %A_PATH%Outputs\Master.mdb GOTO End !!!
		IF NOT EXIST %A_PATH%Outputs\Model.mdb IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelnameerr% ; 7 ; Missing %A_PATH%Outputs\Model.mdb >>%Log_Path%
		REM IF NOT EXIST %A_PATH%Outputs\Model.mdb GOTO End !!!
		IF NOT EXIST %A_PATH%Outputs\!mode!_import.xml IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelnameerr% ; 7 ; Missing %A_PATH%Outputs\!mode!_import.xml >>%Log_Path%
		REM IF NOT EXIST %A_PATH%Outputs\wd_import.xml GOTO End !!!

		ECHO ...........................................>>%SubUpdateLog_PATH%
		ECHO Log file path %SubUpdateLog_PATH%
		ECHO .  >>%SubUpdateLog_PATH%
		ECHO RunTime %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% >>%SubUpdateLog_PATH%
		ECHO .  >>%SubUpdateLog_PATH%
		ECHO Report from import process:>>%SubUpdateLog_PATH%
		ECHO ...........................................>>%SubUpdateLog_PATH%
		rem %MU_Path%Bin\muIOBatch.exe -m "%A_PATH%Outputs\!mode!_import.xml" >>%SubUpdateLog_PATH%
		%MU_Path%bin\muIOBatch.exe -m %A_PATH%Outputs\!mode!_import.xml -t %MU_Path%"MIKE URBAN\Templates\mudefault.mdb" >>%SubUpdateLog_PATH%

		ECHO ...........................................>>%SubUpdateLog_PATH%
		ECHO End >>%SubUpdateLog_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Finishing update model based on MASTER >>%Log_Path%
	)
	REM PAUSE
	
	:Python
	IF EXIST %A_PATH%Outputs\Selection.txt (
		ECHO -run Python procedure with model: %%G
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Starting Pythons scripts >>%Log_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Starting Pythons scripts >>%SubLog_PATH%
		IF NOT EXIST %PY_PATH% IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelnameerr% ; 7 ; Correct PY path %PY_PATH%  >>%Log_PATH%
		IF NOT EXIST %PY_PATH% IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelnameerr% ; 7 ; Correct PY path %PY_PATH%  >>%SubLog_PATH%
		IF NOT EXIST %A_PATH%*.py IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelnameerr% ; 7 ; Missing script .PY >>%Log_PATH%
		IF NOT EXIST %A_PATH%*.py IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelnameerr% ; 7 ; Missing script .PY >>%SubLog_PATH%
		
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Starting PointAssignment.py >>%Log_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Starting PointAssignment.py >>%SubLog_PATH%
		Start /wait %PY_PATH% %A_PATH%PointAssignment.py %~n0.bat
    
    IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Starting mw_Junction_DMT.py >>%Log_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Starting mw_Junction_DMT.py >>%SubLog_PATH%
    Start /wait %PY_PATH% %A_PATH%mw_Junction_DMT.py %~n0.bat
	)
	REM PAUSE
	
	:Comparison
	IF EXIST %A_PATH%Outputs\Selection.txt (
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Starting comparison procedure %A_PATH%Comparison_update.vbs >>%Log_Path%
		IF NOT EXIST %A_PATH%Comparison_update.vbs IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelnameerr% ; 5 ; Missing %A_PATH%Comparison_update.vbs >>%Log_Path%
		REM IF NOT EXIST %A_PATH%Comparison_update.vbs GOTO End !!!
    

		Start /wait %A_PATH%Comparison_update.vbs
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Model: %%~nf.mdb copying to %A_PATH%Oututs\Model_update.mdb >>%Log_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Model: %%~nf.mdb copying to %A_PATH%Oututs\Model_update.mdb >>%SubLog_PATH%
    copy %A_PATH%Outputs\Model.mdb %A_PATH%Outputs\Model_update.mdb
	)
	REM PAUSE
	
	:PrepXML
	IF EXIST %A_PATH%Outputs\Selection.txt (
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Starting path correction %A_PATH%PrepareXML.vbs >>%Log_Path%
		IF NOT EXIST %A_PATH%PrepareXML.vbs IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelnameerr% ; 5 ; Missing %A_PATH%PrepareXML.vbs >>%Log_Path%
		REM IF NOT EXIST %A_PATH%PrepareXML.vbs GOTO End !!!

		IF NOT EXIST %A_PATH%Outputs\!mode!_export.xml IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelnameerr% ; 5 ; Missing %A_PATH%Outputs\!mode!_export.xml >>%Log_Path%
		REM IF NOT EXIST %A_PATH%Outputs\wd_export.xml GOTO End !!!

		Start /wait %A_PATH%PrepareXML.vbs "%A_PATH%Outputs\!mode!_export.xml"

		IF NOT EXIST %A_PATH%Outputs\!mode!_export.xml IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelnameerr% ; 5 ; Missing %A_PATH%Outputs\!mode!_export.xml >>%Log_Path%
		REM IF NOT EXIST %A_PATH%Outputs\wd_export.xml GOTO End  !!!
	)
	REM PAUSE
	
	:Export
	IF EXIST %A_PATH%Outputs\Selection.txt (
		ECHO ...........................................>>%SubUpdateLog_PATH%
		REM ECHO RunTime %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% >>%SubUpdateLog_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Starting export model to Epanet %A_PATH%Outputs\Model.inp >>%Log_Path%
		IF EXIST %A_PATH%Outputs\Model.mdb IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Founded %A_PATH%Outputs\Model.mdb >>%Log_Path%
		IF NOT EXIST %A_PATH%Outputs\Model.mdb IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Error: Missing %A_PATH%Outputs\Model.mdb >>%Log_Path%
		REM IF NOT EXIST %A_PATH%Outputs\Model.mdb GOTO End !!!
		IF EXIST %A_PATH%Outputs\!mode!_export.xml IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Founded %A_PATH%Outputs\wd_export.xml >>%Log_Path%
		IF NOT EXIST %A_PATH%Outputs\!mode!_export.xml IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Error: Missing %A_PATH%Outputs\wd_export.xml >>%Log_Path%
		REM IF NOT EXIST %A_PATH%Outputs\wd_export.xml GOTO End !!!
		IF EXIST %MU_Path%Bin\muIOBatch.exe IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Founded %MU_Path%Bin\muIOBatch.exe >>%Log_Path%
		IF NOT EXIST %MU_Path%Bin\muIOBatch.exe IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Error: Missing %MU_Path%Bin\muIOBatch.exe >>%Log_Path%
		REM IF NOT EXIST %MU_Path%Bin\muIOBatch.exe GOTO End !!!


		ECHO .  >>%SubUpdateLog_PATH%
		ECHO Export data into INP script:>>%SubUpdateLog_PATH%
		ECHO ...........................................>>%SubUpdateLog_PATH%
		REM %MU_Path%Bin\muIOBatch.exe -m "%A_PATH%Outputs\wd_export.xml" >>%SubUpdateLog_PATH%
		%MU_Path%bin\muIOBatch.exe -m %A_PATH%Outputs\!mode!_export.xml -t %MU_Path%"MIKE URBAN\Templates\mudefault.mdb" >>%SubUpdateLog_PATH%

		ECHO ...........................................>>%SubUpdateLog_PATH%
		ECHO End >>%SubUpdateLog_PATH%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Finishing export model to Epanet %A_PATH%Outputs\Model.inp >>%Log_Path%
	)
	REM PAUSE
	
	:Epanet
	IF EXIST %A_PATH%Outputs\Selection.txt (
		DEL %A_PATH%EpanetWrapper\Model.inp
		DEL /Q %A_PATH%EpanetWrapper\Runs\Model\*.*
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Starting Epanet calculation >>%Log_Path%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; DELeting previous inputs %A_PATH%EpanetWrapper\Model.inp >>%Log_Path%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ;%modulename% ; %~n0 ; %levelname% ; 7 ; DELeting previous results %A_PATH%EpanetWrapper\Runs\Model\*.* >>%Log_Path% 

		COPY %A_PATH%Outputs\Model.inp %A_PATH%EpanetWrapper\Model.inp
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Copying model into %A_PATH%EpanetWrapper\Model.inp for Epanet >>%Log_Path%
		REM PAUSE

		chcp 1250
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Starting Epanet calculation >>%Log_Path%
		IF EXIST %A_PATH%EpanetWrapper\Model.inp IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Founded %A_PATH%EpanetWrapper\Model.inp >>%Log_Path%
		IF NOT EXIST %A_PATH%EpanetWrapper\Model.inp IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Error: Missing %A_PATH%EpanetWrapper\Model.inp >>%Log_Path%
		REM IF NOT EXIST %A_PATH%EpanetWrapper\Model.inp GOTO End !!!
		IF EXIST %A_PATH%EpanetWrapper\EPANET.exe IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Founded %A_PATH%EpanetWrapper\EPANET.exe >>%Log_Path%
		IF NOT EXIST %A_PATH%EpanetWrapper\EPANET.exe IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Error: Missing %A_PATH%EpanetWrapper\EPANET.exe >>%Log_Path%
		REM IF NOT EXIST %A_PATH%EpanetWrapper\EPANET.exe GOTO End !!!

		"%A_PATH%EpanetWrapper\EPANET.exe" "inpfilename:%A_PATH%EpanetWrapper\Model.inp" "now:Now" hydraulicrun:Model commaseparator:. csvseparator:; saveres:True min:10 max:90
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Finishing Epanet calculation >>%Log_Path%
		REM PAUSE
		IF EXIST %A_PATH%EpanetWrapper\Runs\Model\Model.rpt IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Founded %A_PATH%EpanetWrapper\Runs\Model\Model.rpt >>%Log_Path%
		IF NOT EXIST %A_PATH%EpanetWrapper\Runs\Model\Model.rpt IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Error: Missing %A_PATH%EpanetWrapper\Runs\Model\Model.rpt >>%Log_Path%
		REM IF NOT EXIST %A_PATH%EpanetWrapper\Runs\Model\Model.rpt GOTO End !!!

		COPY %A_PATH%EpanetWrapper\Runs\Model\Model.rpt %A_PATH%Outputs\Model.sum
		IF EXIST %A_PATH%Outputs\Model.sum IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Founded %A_PATH%Outputs\Model.sum >>%Log_Path%
		IF NOT EXIST %A_PATH%Outputs\Model.sum IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Error: Missing %A_PATH%Outputs\Model.sum >>%Log_Path%
		REM IF NOT EXIST %A_PATH%Outputs\Model.sum GOTO End !!!
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 7 ; Copying report from Epanet calculation %A_PATH%Outputs\Model.sum >>%Log_Path%  
	)
	REM PAUSE
	
	:Sendemail_update
	IF EXIST %A_PATH%Outputs\Selection.txt (
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelnamechap% ; 8 ; Epanet report %A_PATH%Outputs\Model.sum >>%Log_Path%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 8 ; Sending email from Epanet calculation %A_PATH%Outputs\Model.sum >>%Log_Path%
		
		ECHO Send update model report by mail
		Call %A_PATH%Update_sendemail.bat
	)
	REM PAUSE
	
	:Compact
	IF EXIST %A_PATH%Outputs\Selection.txt (
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 8 ; Compact and repairing %A_PATH%Outputs\Master.mdb >>%Log_Path%

		REM Call "%A_PATH%Outputs\Master.mdb" /compact
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 8 ; Compact and repairing %A_PATH%Outputs\Model.sum >>%Log_Path%

		REM Call "%A_PATH%Outputs\Model.mdb" /compact
		REM PAUSE
	)
		
	
	
	:Transport_OUT
	IF EXIST %A_PATH%Outputs\Selection.txt (
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelnamechap% ; 10 ; Output transfer to Temp >>%Log_Path%
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 10 ; Starting outputs transfer to %A_PATH%Temp >>%Log_Path%
		Del "%A_PATH%Outputs\Selection.txt"
    Start /wait %VBS_PATH% %A_PATH%CopyToTemp.vbs
		
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 10 ; Deleting source directory from comaprison %A_PATH%Temp\%%G >>%Log_Path%
		RD %A_PATH%Temp\%%G /s/q
		IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; !model! ; %modulename% ; %~n0 ; %levelname% ; 6 ; Finished transfer Outputs to Temp directory >>%Log_PATH%
	REM important ENDLOCAL of inner variable holding mode and argument
	ENDLOCAL	
	)
	REM PAUSE
	
	
)


:Archive_OUT
IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; ; %modulename% ; %~n0 ; %levelnamechap% ; 9 ; Inputs archivation >>%Log_Path%
IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; ; %modulename% ; %~n0 ; %levelname% ; 9 ; Starting outputs archivation %A_PATH%Archive\*.* >>%Log_Path%

	REM ECHO Archive Outputs
	REM for %%f in ( '"%A_PATH%Outputs"\*.*' ) do (
		REM SET fname=%%~nf
		REM ECHO %%~nf
		REM COPY %%f "%A_PATH%Archive\%DD%.%MM%.%YYYY% %Time:~0,2%.%Time:~3,2%.%Time:~6,2%_%%~nf%%~xf"
	REM )
	REM IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %modulename% ; %~n0 ; %levelname% ; 9 ; Finished outputs archivation A_PATH%Archive\*.* >>%Log_Path%

REM PAUSE

REM :BackupDEL
REM IF EXIST %A_PATH%Outputs\Selection.txt (
	REM IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %modulename% ; %~n0 ; %levelname% ; 9 ; Archive maintenance A_PATH%Archive >>%Log_Path%

	REM ECHO Delete older files then D (Days) in Backup dir %A_PATH%Archive
	REM forfiles -p "%A_PATH%Archive" -s -m *.* /D -60 /C "cmd /c del @path"
	REM IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; %modulename% ; %~n0 ; %levelname% ; 9 ; Deleted old data in A_PATH%Archive\*.* >>%Log_Path%
REM )
REM PAUSE


:End
IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; ; %modulename% ; %~n0 ; %levelname% ; 0 ; DELeting flags %A_PATH%Flag_Update.txt >>%Log_Path%

DEL "%A_PATH%Flag_Update.txt"
IF %LOG% == 1 ECHO %DD%.%MM%.%YYYY% %Time:~0,2%:%Time:~3,2%:%Time:~6,2% ; ; %modulename% ; %~n0 ; %levelname% ; 0 ; ** ** ** Closing script >>%Log_Path%
REM PAUSE
REM EXIT


