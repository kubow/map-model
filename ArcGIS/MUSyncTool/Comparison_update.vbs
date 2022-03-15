On Error Resume Next
Err.Clear

Dim objShell
Dim oFSO
Dim currFolder

Set objShell = Wscript.CreateObject("WScript.Shell")
Set oFSO = CreateObject("Scripting.FileSystemObject")
currFolder = oFSO.GetParentFolderName(Wscript.ScriptFullName)

DBPath = currFolder & "\Outputs\Comparison.mdb"
LOGPath = currFolder & "\ErrorToLogFile.vbs"
VBSprom = " ; VBS ; Comparison_update ; DEBUG ; 5 ; Start"
VBSpromErr = " ; VBS ; Comparison_update ; ERROR ; 5 ; Error"

objShell.Run ("""" & LOGPath & """ """ & VBSprom & """")	

Set AccessApp = GetObject(DBPath, "Access.Application")
AccessApp.Run "MainComparisonUpdate"

Set AccessApp = Nothing
   
                                                           
If Err.Number <> 0 Then
    AccessApp.Quit
    'close the access app

	'MsgBox("Test")

        objShell.Run ("""" & LOGPath & """ """ & VBSpromErr & """")
	Set objShell = Nothing
        

    Err.Clear
End If
AccessApp.Quit
On Error GoTo 0


'it will continue here