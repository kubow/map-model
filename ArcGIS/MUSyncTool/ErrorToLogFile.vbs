On Error Resume Next
Err.Clear

'MsgBox(Wscript.Arguments(0)) 
set objFSO = CreateObject("Scripting.FileSystemObject")

currFolder = oFSO.GetParentFolderName(Wscript.ScriptFullName)

set objFile = objFSO.OpenTextFile(currFolder & "\Outputs\Logfile.log", 8, True) 
objFile.WriteLine(Now & Wscript.Arguments(0)) 
objFile.Close

If Err.Number <> 0 Then
    AccessApp.Quit
    'close the access app

	'MsgBox("Test")


    Err.Clear
End If
On Error GoTo 0

'it will continue here