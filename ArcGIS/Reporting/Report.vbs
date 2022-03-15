On Error Resume Next
Err.Clear
	
	Set objFSO=CreateObject("Scripting.FileSystemObject")
    'Dim f As Object
    'Dim objShell
    Const DBPath = "c:\DHI\RptTool\Report.mdb"
	oDate = Right(String(2, "0") & Day(Now), 2) & "." & Right(String(2, "0") & Month(Now), 2) & "." & Year(Now) & " " & Time()
	Set f=objFSO.OpenTextFile("c:\DHI\RptTool\Logfile.log", 8)
    f.write oDate & " - VBS - Run - Starting SQL runner" & vbNewLine
	f.Close()
	
    Set AccessApp = GetObject(DBPath, "Access.Application")
    AccessApp.Run "RunBunchQry"
    Set AccessApp = Nothing
	
	'Dim s, strLine
	Set s=objFSO.OpenTextFile("c:\DHI\RptTool\RunSQL.txt", 1)
	
	Do While Not s.AtEndOfStream
		strLine = s.readline
		If Instr(strLine,"INNER JOIN") > 0 Then
			If Instr(strLine,";") > 0 Then
				SQLText = Left(strLine, Len(strLine) - 1)
			Else
				SQLText = strLine
			End If
			Set AccessApp = GetObject(DBPath, "Access.Application")
			AccessApp.Run "RunInrJoinQry", SQLText
			'AccessApp.Run "RunBunchQry_Temp", SQLText
			AccessApp.Close
			Set AccessApp = Nothing
			WScript.Sleep 5000
			WScript.Run "call 'c:\DHI\RptTool\Report.mdb' /compact"
		End If
	Loop
	s.Close
	'WScript.Run "taskkill /im MSACCESS.exe"

Set f=objFSO.OpenTextFile("c:\DHI\RptTool\Logfile.log", 8)
		
If Err.Number <> 0 Then
    AccessApp.Quit
	f.write oDate()&" - VBS - Err - Script Failed (" & Err & ")" & vbNewLine
    'close the access app
    f.Close()
    Err.Clear
Else
	AccessApp.Quit
	f.write oDate()&" - VBS - Run - Finished !" & vbNewLine
	f.Close()
End If
