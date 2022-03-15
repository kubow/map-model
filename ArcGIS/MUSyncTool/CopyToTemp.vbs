'-------------------------------
'Developped by Jakub Vajda
' end of - 04 - 2016 - - - - - -
'Use for Copying Outputs > Temp 
'-------------------------------

Const ForReading = 1
Const ForWriting = 2
Const ForAppending = 8
Const adOpenDynamic = 2
Const ShowWindow = 1
Const DontShowWindow = 0
Const WaitUntilFinished = true

Dim oFSO, oShell
Dim currFolder, FolderName
Dim LogFile, SubLogFile
Dim LogPath, SubLogPath, LogStr

Dim connStr, objConn
Dim rs
Dim msg, lev

Dim Selection, RunTime, ModelName, Mode, MDate, Argument, Area, BufferArea, Description, RunScript
Dim sSelection, sModelName, sMode, sMDate, sArgument, sArea, sBuffArea, sDescription, sRunScript 'As String
Dim Model
Dim sMonth, sDay

Selection = "Selection"
RunTime = "RunTime"
ModelName = "Model"
Mode = "Mode"
MDate = "MDate"
Argument = "Argument"
Area = "Area"
BufferArea = "BufferArea"
Description = "Description"
RunScript = "RunScript"

Set oFSO = CreateObject("Scripting.FileSystemObject")
Set oShell = WScript.CreateObject("WSCript.shell")
currFolder = oFSO.GetParentFolderName(Wscript.ScriptFullName)

LogPath = oFSO.GetParentFolderName(Wscript.ScriptFullName) & "\Logfile.log"
SubLogPath = oFSO.GetParentFolderName(Wscript.ScriptFullName) & "\Outputs\Logfile.log"
connStr = "Provider=Microsoft.ACE.OLEDB.12.0; Data Source=" & currFolder & "\Outputs\Model.mdb"

If TableExists("ModelRegister") Then
	'Model is registered - read variables from 'ModelRegister' table
	Set objConn = CreateObject("ADODB.Connection")
	Set rs = CreateObject("ADODB.Recordset")
	objConn.Open(ConnStr)
	
	REM objConn.CursorLocation = adUseClient
	objConn.Execute "SELECT COUNT(*) FROM ModelRegister" ', Application.GetNewConnection
	REM MsgBox objConn.Fields(0).Value 'objConn.RecordCount
	
	rs.CursorType = adOpenDynamic
	rs.Open "ModelRegister", objConn
	
	If rs.RecordCount < 2 Then
		sSelection = rs.Fields(Selection).Value
		sModelName = rs.Fields(ModelName).Value
		sMode = rs.Fields(Mode).Value
		sMDate = rs.Fields(MDate).Value
		sArgument = rs.Fields(Argument).Value
		sRunScript = rs.Fields(RunScript).Value
		Model = sMode & "_" & sModelName & "_" & Year(sMDate) & Right("0" & Month(sMDate),2) & Right("0" & Day(sMDate),2)
		msg = "Variables from table 'ModelRegister' loaded... "
	Else
		msg = "Bad number of records (" & rs.RecordCount & "), cannot continue..."
	End If
	
	REM rs.Close
	objConn.Close
	Set rs = Nothing
	Set objConn = Nothing
	Call WriteLog(msg, "d")
Else
	msg = "Model is not registered, please register first... "
	Model = "Model"
	Call WriteLog(msg, "w")
End If

If sSelection = 1 Then
	'copy files to temp with prepared variables
	If Len(Month(sMDate)) = 1 Then
		sMonth = "0" & Month(sMDate)
	Else
		sMonth = Month(sMDate)
	End If
	If Len(Day(sMDate)) = 1 Then
		sDay = "0" & Day(sMDate)
	Else
		sDay = Day(sMDate)
	End If
	
	FolderName = sMode & "_" & sModelName & "_" & Year(sMDate) & sMonth & sDay & "_" & Left(sRunScript,1) & sArgument
	
	If oFSO.FolderExists(currFolder & "\Temp\" & FolderName) Then
		msg = "Folder is already created, deleting content..."
	Else
		oFSO.CreateFolder(currFolder & "\Temp\" & FolderName)
	End If
	
	msg = "Copying files: xcopy " & currFolder & "\Outputs " & currFolder & "\Temp\" & FolderName & ""
	Call WriteLog(msg, "d")
	'oShell.run "xcopy " & currFolder & "\Outputs " & currFolder & "\Temp\" & FolderName & " /Y /E", DontShowWindow, WaitUntilFinished
	oShell.run "xcopy " & currFolder & "\Outputs " & currFolder & "\Temp\" & FolderName & " /Y", DontShowWindow, WaitUntilFinished
	REM MsgBox "a"
	oFSO.DeleteFile (currFolder & "\Outputs\*.*")
	'oShell.run "rd " & currFolder & "\Outputs\ /S /Q", DontShowWindow, WaitUntilFinished
	If oFSO.FolderExists(currFolder & "\Outputs\ModelAttributes\") Then
		oFSO.DeleteFile (currFolder & "\Outputs\ModelAttributes\*.*")
	End If
	'Kill currFolder & "\Outputs\ModelAttributes\*.*"    ' delete all files in the folder
    'oShell.run "rmdir " & currFolder & "\Outputs\ModelAttributes\"  ' delete folder
	'oShell.run "rd " & currFolder & "\Outputs\ModelAttributes\ /S /Q", DontShowWindow, WaitUntilFinished
	msg = "Finished deleting " & currFolder & "\Outputs\*.*"
  Call WriteLog(msg, "d")
ElseIf sSelection = 0 Then
	'copy files to temp with prepared variables
	msg = "Model not selected to run, skipping ...."
	Call WriteLog(msg, "w")
Else
	msg = "Selection contains unknown value, plesere re-register the model ...."
	Call WriteLog(msg, "w")
End If


Function WriteLog(msg, lev)
	If lev = "i" Then
		logStr = timeStamp() & " ; " & Split(Model, ".")(0) & " ; VBS ; " & Split(WScript.ScriptName, ".")(0) & " ; INFO ; 2 ; " & msg & vbNewLine
	ElseIf lev = "w" Then 
		logStr = timeStamp() & " ; " & Split(Model, ".")(0) & " ; VBS ; " & Split(WScript.ScriptName, ".")(0) & " ; WARNING ; 2 ; " & msg & vbNewLine
	Else 
		logStr = timeStamp() & " ; " & Split(Model, ".")(0) & " ; VBS ; " & Split(WScript.ScriptName, ".")(0) & " ; DEBUG ; 2 ; " & msg & vbNewLine
	End If
	If oFSO.FileExists(LogPath) And oFSO.FileExists(SubLogPath) Then
		REM oDate = Right(String(2, "0") & Day(Now), 2) & "." & Right(String(2, "0") & Month(Now), 2) & "." & Year(Now) & " " & DatePart("h",Time()) & ":" & DatePart("m",Time()) & ":" & DatePart("s",Time())
		Set LogFile = oFSO.OpenTextFile(LogPath, ForAppending, True)
		Set SubLogFile = oFSO.OpenTextFile(SubLogPath, ForAppending, True)
		LogFile.Write(logStr)
		SubLogFile.Write(logStr)
		LogFile.Close
		SubLogFile.Close
	ElseIf oFSO.FileExists(LogPath) Then
		Set LogFile = oFSO.OpenTextFile(LogPath, ForAppending, True)
		LogFile.Write(logStr)
		LogFile.Close
	ElseIf oFSO.FileExists(SubLogPath) Then
		Set SubLogFile = oFSO.OpenTextFile(SubLogPath, ForAppending, True)
		SubLogFile.Write(logStr)
		SubLogFile.Close
	Else
		MsgBox ("Did not find log file : cirtical error..")
	End If
End Function

Function timeStamp()
    Dim t 
    t = Now
    timeStamp = Right("0" & Day(t),2)  & "." & _
	Right("0" & Month(t),2)  & "." & _
	Year(t) & " " & _
	Right("0" & Hour(t),2) & ":" & _
	Right("0" & Minute(t),2) & ":" & _
    Right("0" & Second(t),2)
End Function

Function TableExists(TabletoFind)
    TableExists = False
    Set adoxConn = CreateObject("ADOX.Catalog")
    Set objConn = CreateObject("ADODB.Connection")
	
    objConn.Open(ConnStr)
    adoxConn.ActiveConnection = objConn
    IsThere = False
    For Each Table in adoxConn.Tables
        If LCase(Table.Name) = LCase(TabletoFind) Then
            IsThere = True
            Exit For
        End If
    Next
    objConn.Close
    Set objConn = Nothing
    Set adoxConn = Nothing
    If IsThere Then TableExists = True
End Function