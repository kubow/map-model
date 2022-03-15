'-------------------------------
'Developped by Jakub Vajda
' end of - 04 - 2016 - - - - - -
'Use for Copying Outputs > Temp 
'-------------------------------

Const ppAdvanceOnTime = 2
Const ppShowTypeKiosk = 3
Const ppSlideShowDone = 5

Set oFSO = CreateObject("Scripting.FileSystemObject")
Set oShell = WScript.CreateObject("WSCript.shell")
currFolder = oFSO.GetParentFolderName(Wscript.ScriptFullName)

Set objPPT = CreateObject("PowerPoint.Application")



Set objPresentation = objPPT.Presentations.Open(currFolder & "\Manager.ppsm")
rem objPPT.Visible = False
'objPresentation.Run "OnSlideShowPageChange"

Set objSlideShow = objPresentation.SlideShowSettings.Run.View
objPPT.Run "OnSlideShowPageChange"