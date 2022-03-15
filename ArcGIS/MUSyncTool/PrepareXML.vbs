On Error Resume Next
Err.Clear

Dim xmlDoc
Dim objShell
Dim oFSO
Dim currFolder

'Set xmlDoc = CreateObject("Microsoft.XMLDOM")
set xmlDoc = CreateObject("MSXML2.DOMDocument")
Set objShell = Wscript.CreateObject("WScript.Shell")
Set oFSO = CreateObject("Scripting.FileSystemObject")
currFolder = oFSO.GetParentFolderName(Wscript.ScriptFullName)

xmlDoc.Async = "False"
'xmlDoc.Load("wd_export.xml")
FileXML = WScript.Arguments.Item(0)

        LOGPath = currFolder & "\ErrorToLogFile.vbs"
        VBSprom = " ; VBS ; PrepareXML ; DEBUG ; 7 ; Start"
        VBSpromErr = " ; VBS ; PrepareXML ; ERROR ; 7 ; Error"

if oFSO.FileExists(FileXML) then 
        xmlDoc.Load(FileXML)       
        
        objShell.Run ("""" & LOGPath & """ """ & VBSprom & """")	
        
        Set colNodes=xmlDoc.selectNodes("//muIO/Task/a")
        
        counter = colNodes.length 
        
        For Each objNode in colNodes
        	If InStr(objNode.getAttribute("Source"),":\") > 0 Or InStr(objNode.getAttribute("Source"),"\\") > 0 Then
        		'Wscript.Echo objNode.getAttribute("Source")
        		strArr = Split(objNode.getAttribute("Source"), "\")
				'MsgBox currFolder & "\Outputs\" & strArr(UBound(strArr))
				objNode.setAttribute("Source") = currFolder & "\Outputs\" & strArr(UBound(strArr))
        		'Wscript.Echo "Find: " & objNode.getAttribute("Source") & VbNewLine & "Replace: " & currFolder & "\Outputs\" & strArr(UBound(strArr))
        	End If
        	If InStr(objNode.getAttribute("Target"),":\") > 0 Or InStr(objNode.getAttribute("Source"),"\\") > 0 Then
        		'Wscript.Echo objNode.getAttribute("Target")
        		strArr = Split(objNode.getAttribute("Target"), "\")
				'MsgBox currFolder & "\Outputs\" & strArr(UBound(strArr))
				objNode.setAttribute("Target") = currFolder & "\Outputs\" & strArr(UBound(strArr))
        		'Wscript.Echo "Find: " & objNode.getAttribute("Target") & VbNewLine & "Replace: " & currFolder & "\Outputs\" & strArr(UBound(strArr))
        	End If
        Next
        
        REM xmlDoc.Save "wd_export.xml"
        xmlDoc.Save(FileXML)
        
else
  objShell.Run ("""" & LOGPath & """ """ & VBSpromErr & """")
	Set objShell = Nothing

end if 

If Err.Number <> 0 Then
  objShell.Run ("""" & LOGPath & """ """ & VBSpromErr & """")
	Set objShell = Nothing   

  Err.Clear
End If

