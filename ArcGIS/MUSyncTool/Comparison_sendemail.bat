echo off
echo MIKE Urban-GIS Update-comparison procedure script is run, send report...

SET A_PATH=%~dp0
echo   Application directory %A_PATH%
rem pause

rem :Comparison
rem echo 
rem Start /wait %A_PATH%Comparison.vbs
rem pause

:Mail
Call %A_PATH%SendMail_GVar.bat
echo General parameters for SendEmail.exe are loaded.
echo SMTP = %SMTP%
rem pause

:SendEmailCalibration
SET TO=o.kolovrat@dhi.cz;k.kubikova@dhi.cz;o.janku@dhi.cz;
SET SUBJECT=MU-GIS_Update/Comparison-report
rem SET BODY=Test
SET BODYFILE=%A_PATH%Body.txt
rem SET ATTACH=%A_PATH%Body\*Time*.txt - not in function
SET ATTACH1=%A_PATH%Outputs\wd_Rep_Control.pdf
SET ATTACH2=%A_PATH%Outputs\wd_Rep_Comparison.pdf
SET ATTACH3=%A_PATH%Outputs\wd_Rep_ModelFlags.pdf
SET PRIORITY=normal
SET LOGFILE=%A_PATH%Outputs\Comparison-sendemail.log                      
             
SET MAIL= %A_PATH%%SOFT% %FROM% %TO% -subject "%SUBJECT%" -bodyfile "%BODYFILE%" -smtp %SMTP% -port %PORT% -username %USERNAME% -password %PASSWORD% -attachment "%ATTACH1%" -attachment "%ATTACH2%" -attachment "%ATTACH3%" -disablessl -priority "%PRIORITY%" -logfile "%LOGFILE%"
echo %MAIL%

Start /wait %MAIL%
rem pause

:End
rem pause

