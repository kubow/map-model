Attribute VB_Name = "Module1"
Option Compare Database

Global GBL_Category As String
Global GBL_Icount As Long

Public sQuery As String
Public sQueryB As String
Public sColumn As String
Public sColumnB As String
Public sPath As String
Public sMsg As String
Public sExport As String

Option Explicit

Sub Report()
' Used for reporting to given directory name

Dim RS As Recordset ' Managing id_inv list
Dim SQL As String ' General purpose SQL
Dim Serie As Variant ' Setting id inv to var Serie
Dim Ser As Variant
Dim StrCriteria As String ' Limiting reports to Criteria
Dim strPath As String ' Output folder
Dim Param As Object
Dim i, ColID, ColSID, colPTS, ColName, ColMat As Integer
Dim FSO As Object
Dim oFile As Object
Set FSO = CreateObject("Scripting.FileSystemObject")
' Define output folder path + logfile
strPath = "C:\DHI\_NR\Output\"
Set oFile = FSO.CreateTextFile(strPath & "LogFile.txt")

' Load investments to variable
SQL = "SELECT * FROM 0_INVbyNR_Year_MaxTechInclName;"
Set RS = CurrentDb.OpenRecordset(SQL)

With RS
    .MoveLast
    .MoveFirst
    Serie = .GetRows(.RecordCount)
End With

RS.Close
' Start generating reports
ColID = 0
colPTS = 1
ColSID = 2
ColName = 3
ColMat = 4

' 3 / Report investment by representant SID

For i = LBound(Serie, 2) To UBound(Serie, 2)
        SQL = "SELECT nr_segment.segid, nr_segment.id_inv, nr_segment.nazev_inv, nr_segment.diameter, nr_segment.material, nr_segment.datasource, nr_segment.cyear, RegForm_1.id_cust FROM (nr_segment INNER JOIN [0_SID Selection] ON nr_segment.segid = [0_SID Selection].segid) INNER JOIN RegForm_1 ON nr_segment.id_inv = RegForm_1.id_inv WHERE (((nr_segment.segid) = " & Chr(34) & Serie(ColSID, i) & Chr(34) & ") And ((nr_segment.id_inv) = " & Serie(ColID, i) & ")) ORDER BY nr_segment.id_inv;"
        Call RedefRptSQL("ReportSegments", SQL, strPath & "3C_NREvalChartRepresentatives\" & "Graph_" & Serie(ColName, i) & ".pdf", oFile)
        oFile.WriteLine (Now() & " - 3 - " & SQL)
Next i

oFile.WriteLine (Now() & " - 3 (finish) - " & SQL)

' 4 / Report Segment Graphs (all)
'For i = LBound(Serie, 2) To UBound(Serie, 2)
'        'SQL = "SELECT nr_segment.segid, nr_segment.id_inv, nr_segment.nazev_inv, nr_segment.diameter, nr_segment.material, nr_segment.datasource, nr_segment.cyear, RegForm_1.id_cust FROM (nr_segment INNER JOIN [0_SID Selection] ON nr_segment.segid = [0_SID Selection].segid) INNER JOIN RegForm_1 ON nr_segment.id_inv = RegForm_1.id_inv WHERE (((nr_segment.id_inv) = " & Serie(ColID, i) & ")) ORDER BY nr_segment.id_inv;"
'        SQL = "SELECT nr_segment.segid, nr_segment.id_inv, nr_segment.nazev_inv, nr_segment.diameter, nr_segment.material, nr_segment.datasource, nr_segment.cyear, RegForm_1.id_cust FROM (nr_segment INNER JOIN [0_SID Selection] ON nr_segment.segid = [0_SID Selection].segid) INNER JOIN RegForm_1 ON nr_segment.id_inv = RegForm_1.id_inv WHERE (((nr_segment.segid) = " & Chr(34) & Serie(ColSID, i) & Chr(34) & ") And ((nr_segment.id_inv) = " & Serie(ColID, i) & ")) ORDER BY nr_segment.id_inv;"
'        Call RedefRptSQL("ReportSegments", SQL, strPath & "3C_NREvalChart\" & "Graph_" & Serie(ColName, i) & ".pdf", oFile)
'        oFile.WriteLine (Now() & " - 4 - " & SQL)
'Next i

oFile.WriteLine (Now() & " - 4 (finish) - " & SQL)

End Sub

Sub ReportCust()
' Used for reporting to given directory name

Dim RS As Recordset ' Managing id_inv list
Dim SQL As String ' General purpose SQL
Dim Serie As Variant ' Setting id inv to var Serie
Dim Ser As Variant
Dim StrCriteria As String ' Limiting reports to Criteria
Dim strPath As String ' Output folder
Dim Param As Object
Dim i, ColID, ColSID, colPTS, ColName, ColMat As Integer
Dim FSO As Object
Dim oFile As Object
Set FSO = CreateObject("Scripting.FileSystemObject")
' Define output folder path + logfile
strPath = "C:\DHI\_NR\Output\"
Set oFile = FSO.CreateTextFile(strPath & "LogFile.txt")

' Load investments to variable
SQL = "SELECT * FROM 0_INVbyNR_Year_MaxTechInclName;"
Set RS = CurrentDb.OpenRecordset(SQL)

With RS
    .MoveLast
    .MoveFirst
    Serie = .GetRows(.RecordCount)
End With

RS.Close
' Start generating reports
ColID = 0
colPTS = 1
ColSID = 2
ColName = 3
ColMat = 4

' 1 / Report Investment list
SQL = "SELECT [1_INVPricebyMaterialCost_stat].id_cust AS ID, [1_INVPricebyMaterialCost_stat].id_inv AS Èíslo, [1_INVPricebyMaterialCost_stat].name_inv AS Název, [1_INVPricebyMaterialCost_stat].CountOfPipe AS [Poèet potrubí], [1_INVPricebyMaterialCost_stat].LengthKm AS [Délka (Km)], [1_INVPricebyMaterialCost_stat].TPrice AS Cena FROM 1_INVPricebyMaterialCost_stat;"
Call RedefRptSQL("ReportInvestment", SQL, strPath & "InvestmentList.pdf", oFile)
oFile.WriteLine (Now() & " - 1 - " & SQL)

MsgBox "Investment list in " & strPath & " generated, now prepare cofee, begginning to export Report forms..."

' 2 / Report Regform 2

For i = LBound(Serie, 2) To UBound(Serie, 2)
        SQL = "SELECT RegForm_1.*, [5d_RegForm_2-Age_Desc].* FROM RegForm_1 INNER JOIN [5d_RegForm_2-Age_Desc] ON RegForm_1.id_inv = [5d_RegForm_2-Age_Desc].[2j_CriterionsByINV_id_inv] WHERE ((([5d_RegForm_2-Age_Desc].[2j_CriterionsByINV_id_inv]) = " & Serie(ColID, i) & ") And (([5d_RegForm_2-Age_Desc].mat_from) Is Null Or ([5d_RegForm_2-Age_Desc].mat_to) = " & CDbl(Serie(ColMat, i)) & ")) ORDER BY [5d_RegForm_2-Age_Desc].[2j_CriterionsByINV_id_inv], [5d_RegForm_2-Age_Desc].item, [5d_RegForm_2-Age_Desc].sqn;"
        Call RedefRptSQL("Report_Regform_2", SQL, strPath & "3A_RegForm2\" & "Points_" & Serie(ColName, i) & ".pdf", oFile)
        oFile.WriteLine (Now() & " - 2 - " & SQL)
Next i

oFile.WriteLine (Now() & " - 2 (finish) - " & SQL)

' 3 / Report investment by representant SID

For i = LBound(Serie, 2) To UBound(Serie, 2)
        SQL = "SELECT nr_segment.segid, nr_segment.id_inv, nr_segment.nazev_inv, nr_segment.diameter, nr_segment.material, nr_segment.datasource, nr_segment.cyear, RegForm_1.id_cust FROM (nr_segment INNER JOIN [0_SID Selection] ON nr_segment.segid = [0_SID Selection].segid) INNER JOIN RegForm_1 ON nr_segment.id_inv = RegForm_1.id_inv WHERE (((nr_segment.segid) = " & Chr(34) & Serie(ColSID, i) & Chr(34) & ") And ((nr_segment.id_inv) = " & Serie(ColID, i) & ")) ORDER BY nr_segment.id_inv;"
        'SQL = "SELECT nr_segment.segid, nr_segment.id_inv, nr_segment.nazev_inv, nr_segment.diameter, nr_segment.material, nr_segment.datasource, nr_segment.cyear, RegForm_1.id_cust FROM (nr_segment INNER JOIN [0_SID Selection] ON nr_segment.segid = [0_SID Selection].segid) INNER JOIN RegForm_1 ON nr_segment.id_inv = RegForm_1.id_inv WHERE (((nr_segment.segid) = "882") And ((nr_segment.id_inv) = 1)) ORDER BY nr_segment.id_inv;"
        Call RedefRptSQL("ReportSegments", SQL, strPath & "3B_NREvalChartRepresentatives\" & "Graph_" & Serie(ColName, i) & ".pdf", oFile)
        oFile.WriteLine (Now() & " - 3 - " & SQL)
Next i

oFile.WriteLine (Now() & " - 3 (finish) - " & SQL)

' 4 / Report Segment Graphs (all)
'For i = LBound(Serie, 2) To UBound(Serie, 2)
'        SQL = "SELECT nr_segment.segid, nr_segment.id_inv, nr_segment.nazev_inv, nr_segment.diameter, nr_segment.material, nr_segment.datasource, nr_segment.cyear, RegForm_1.id_cust FROM (nr_segment INNER JOIN [0_SID Selection] ON nr_segment.segid = [0_SID Selection].segid) INNER JOIN RegForm_1 ON nr_segment.id_inv = RegForm_1.id_inv WHERE (((nr_segment.id_inv) = " & Serie(ColID, i) & ")) ORDER BY nr_segment.id_inv;"
'        Call RedefRptSQL("ReportSegments", SQL, strPath & "3C_NREvalChart\" & "Graph_" & Serie(ColName, i) & ".pdf", oFile)
'        oFile.WriteLine (Now() & " - 4 - " & SQL)
'Next i
'
'oFile.WriteLine (Now() & " - 4 (finish) - " & SQL)

End Sub

Public Function increment(ivalue As String) As Long
    ' Decide the counter
    If Nz(GBL_Category, "zzzzzzzz") = "" Then
        ' First record
        GBL_Icount = 1
        GBL_Category = ivalue
    ElseIf Nz(GBL_Category, "zzzzzzzz") = ivalue Then
        ' Must be something wrong here - cannot generate row on duplicates
    Else
        GBL_Category = ivalue
        GBL_Icount = GBL_Icount + 1
    End If
    ' Return back to field value
    increment = GBL_Icount
End Function

Public Function GetList(SQL As String, Optional ColumnDelimeter As String = ", ", Optional RowDelimeter As String = vbCrLf) As String
'PURPOSE: to return a combined string from the passed query
'ARGS:
'   1. SQL is a valid Select statement
'   2. ColumnDelimiter is the character(s) that separate each column
'   3. RowDelimiter is the character(s) that separate each row
'RETURN VAL: Concatenated list
'DESIGN NOTES:
'EXAMPLE CALL: =GetList("Select Col1,Col2 From Table1 Where Table1.Key = " & OuterTable.Key)
'BACKUP: Expr1: GetList("Select Day From SourceTable As T1 Where T1.Name = """ & [SourceTable].[Name] & """","",", ")
'SOURCE: http://stackoverflow.com/questions/5174362/microsoft-access-condense-multiple-lines-in-a-table/5174843#5174843

Const PROCNAME = "GetList"
Const adClipString = 2
Dim oConn As ADODB.Connection
Dim oRS As ADODB.Recordset
Dim sResult As String

On Error GoTo ProcErr

Set oConn = CurrentProject.Connection
Set oRS = oConn.Execute(SQL)

sResult = oRS.GetString(adClipString, -1, ColumnDelimeter, RowDelimeter)

If Right(sResult, Len(RowDelimeter)) = RowDelimeter Then
    sResult = Mid$(sResult, 1, Len(sResult) - Len(RowDelimeter))
End If

GetList = sResult
oRS.Close
oConn.Close

CleanUp:
    Set oRS = Nothing
    Set oConn = Nothing

Exit Function
ProcErr:
    ' insert error handler
    Resume CleanUp

End Function

Public Function ConcatRelated(strField As String, _
    strTable As String, _
    Optional strWhere As String, _
    Optional strOrderBy As String, _
    Optional strSeparator = ", ") As Variant
On Error GoTo Err_Handler
    'Purpose:   Generate a concatenated string of related records.
    'Return:    String variant, or Null if no matches.
    'Arguments: strField = name of field to get results from and concatenate.
    '           strTable = name of a table or query.
    '           strWhere = WHERE clause to choose the right values.
    '           strOrderBy = ORDER BY clause, for sorting the values.
    '           strSeparator = characters to use between the concatenated values.
    'Notes:     1. Use square brackets around field/table names with spaces or odd characters.
    '           2. strField can be a Multi-valued field (A2007 and later), but strOrderBy cannot.
    '           3. Nulls are omitted, zero-length strings (ZLSs) are returned as ZLSs.
    '           4. Returning more than 255 characters to a recordset triggers this Access bug:
    '               http://allenbrowne.com/bug-16.html
    'Source: http://allenbrowne.com/func-concat.html
    Dim RS As DAO.Recordset         'Related records
    Dim rsMV As DAO.Recordset       'Multi-valued field recordset
    Dim strSql As String            'SQL statement
    Dim strOut As String            'Output string to concatenate to.
    Dim lngLen As Long              'Length of string.
    Dim bIsMultiValue As Boolean    'Flag if strField is a multi-valued field.
    
    'Initialize to Null
    ConcatRelated = Null
    
    'Build SQL string, and get the records.
    strSql = "SELECT " & strField & " FROM " & strTable
    If strWhere <> vbNullString Then
        strSql = strSql & " WHERE " & strWhere
    End If
    If strOrderBy <> vbNullString Then
        strSql = strSql & " ORDER BY " & strOrderBy
    End If
    Set RS = DBEngine(0)(0).OpenRecordset(strSql, dbOpenDynaset)
    'Determine if the requested field is multi-valued (Type is above 100.)
    bIsMultiValue = (RS(0).Type > 100)
    
    'Loop through the matching records
    Do While Not RS.EOF
        If bIsMultiValue Then
            'For multi-valued field, loop through the values
            Set rsMV = RS(0).Value
            Do While Not rsMV.EOF
                If Not IsNull(rsMV(0)) Then
                    strOut = strOut & rsMV(0) & strSeparator
                End If
                rsMV.MoveNext
            Loop
            Set rsMV = Nothing
        ElseIf Not IsNull(RS(0)) Then
            'NR Specific
            strOut = strOut & "DN " & RS(0) & " " & RS(1) & " v délce " & Round(RS(2), 1) & " m" & strSeparator
        End If
        RS.MoveNext
    Loop
    RS.Close
    
    'Return the string without the trailing separator.
    lngLen = Len(strOut) - Len(strSeparator)
    If lngLen > 0 Then
        ConcatRelated = Left(strOut, lngLen)
    End If

Exit_Handler:
    'Clean up
    Set rsMV = Nothing
    Set RS = Nothing
    Exit Function

Err_Handler:
    MsgBox "Error " & Err.Number & ": " & Err.Description, vbExclamation, "ConcatRelated()"
    Resume Exit_Handler
End Function

Public Function ConcatRelated2(strField As String, _
    strTable As String, _
    Optional strWhere As String, _
    Optional strOrderBy As String, _
    Optional strSeparator = ", ") As Variant
On Error GoTo Err_Handler
    'Purpose:   Generate a concatenated string of related records.
    'Return:    String variant, or Null if no matches.
    'Arguments: strField = name of field to get results from and concatenate.
    '           strTable = name of a table or query.
    '           strWhere = WHERE clause to choose the right values.
    '           strOrderBy = ORDER BY clause, for sorting the values.
    '           strSeparator = characters to use between the concatenated values.
    'Notes:     1. Use square brackets around field/table names with spaces or odd characters.
    '           2. strField can be a Multi-valued field (A2007 and later), but strOrderBy cannot.
    '           3. Nulls are omitted, zero-length strings (ZLSs) are returned as ZLSs.
    '           4. Returning more than 255 characters to a recordset triggers this Access bug:
    '               http://allenbrowne.com/bug-16.html
    'Source: http://allenbrowne.com/func-concat.html
    Dim RS As DAO.Recordset         'Related records
    Dim rsMV As DAO.Recordset       'Multi-valued field recordset
    Dim strSql As String            'SQL statement
    Dim strOut As String            'Output string to concatenate to.
    Dim lngLen As Long              'Length of string.
    Dim bIsMultiValue As Boolean    'Flag if strField is a multi-valued field.
    
    'Initialize to Null
    ConcatRelated2 = Null
    
    'Build SQL string, and get the records.
    strSql = "SELECT " & strField & " FROM " & strTable
    If strWhere <> vbNullString Then
        strSql = strSql & " WHERE " & strWhere
    End If
    If strOrderBy <> vbNullString Then
        strSql = strSql & " ORDER BY " & strOrderBy
    End If
    Set RS = DBEngine(0)(0).OpenRecordset(strSql, dbOpenDynaset)
    'Determine if the requested field is multi-valued (Type is above 100.)
    bIsMultiValue = (RS(0).Type > 100)
    
    'Loop through the matching records
    Do While Not RS.EOF
        If bIsMultiValue Then
            'For multi-valued field, loop through the values
            Set rsMV = RS(0).Value
            Do While Not rsMV.EOF
                If Not IsNull(rsMV(0)) Then
                    strOut = strOut & rsMV(0) & strSeparator
                End If
                rsMV.MoveNext
            Loop
            Set rsMV = Nothing
        ElseIf Not IsNull(RS(0)) Then
            'NR Specific
            strOut = strOut & "DN " & RS(0) & " v ul. " & RS(1) & " v délce " & Round(RS(2), 1) & " m" & strSeparator
        End If
        RS.MoveNext
    Loop
    RS.Close
    
    'Return the string without the trailing separator.
    lngLen = Len(strOut) - Len(strSeparator)
    If lngLen > 0 Then
        ConcatRelated2 = Left(strOut, lngLen)
    End If

Exit_Handler:
    'Clean up
    Set rsMV = Nothing
    Set RS = Nothing
    Exit Function

Err_Handler:
    MsgBox "Error " & Err.Number & ": " & Err.Description, vbExclamation, "ConcatRelated2()"
    Resume Exit_Handler
End Function

'source - http://www.devhut.net/2011/03/09/ms-access-report-change-a-reports-recordsource/
'---------------------------------------------------------------------------------------
' Procedure : RedefRptSQL
' Author    : Daniel Pineault, CARDA Consultants Inc.
' Website   : http://www.cardaconsultants.com
' Purpose   : Redefine an existing report's recordsource
'             Requires opening the form in design mode to make the changes
' Copyright : The following may be altered and reused as you wish so long as the
'             copyright notice is left unchanged (including Author, Website and
'             Copyright).  It may not be sold/resold or reposted on other sites (links
'             back to this site are allowed).
'
' Input Variables:
' ~~~~~~~~~~~~~~~~
' sRptName    ~ Name of the Query to redefine the SQL statement of
' sSQL        ~ SQL Statement to be used to refine the query with
'
' Usage:
' ~~~~~~
' RedefRptSQL "Report1", "SELECT * FROM tbl_Contacts ORDER BY LastName;"
'
' Revision History:
' Rev       Date(yyyy/mm/dd)        Description
' **************************************************************************************
' 1         2009-07-13                 Initial Release
'---------------------------------------------------------------------------------------
Function RedefRptSQL(sRptName As String, sSQL As String, strPath As String, oFile As Object)
On Error GoTo Error_Handler
    Dim Rpt     As Report
 
    DoCmd.OpenReport sRptName, acViewDesign, , , acHidden 'Open in design view so we can
                                                          'make our changes
    Set Rpt = Application.Reports(sRptName)
    Rpt.RecordSource = sSQL                               'Change the RecordSource
    DoCmd.OutputTo acOutputReport, sRptName, acFormatPDF, strPath, False    'Export to pdf
    DoCmd.Close acReport, sRptName, acSaveYes             ' save our changes

Error_Handler_Exit:
    On Error Resume Next
    Set Rpt = Nothing
    Exit Function
 
Error_Handler:
    'MsgBox "The following error has occured." & vbCrLf & vbCrLf & _
            "     Error Number: " & Err.Number & vbCrLf & _
            "     Error Source: RedefRptSQL" & vbCrLf & _
            "     Error Description: " & Err.Description, _
            vbCritical, "An Error has Occured!"
    oFile.WriteLine (Now() & " - error - " & sSQL)
    oFile.WriteLine ("- - - errDesc - " & Err.Number & " - " & Err.Description)
    Resume Error_Handler_Exit
End Function
Public Function ConcatRelated3(strField As String, _
    strTable As String, _
    Optional strWhere As String, _
    Optional strOrderBy As String, _
    Optional strSeparator = ", ") As Variant
On Error GoTo Err_Handler
    'Purpose:   Generate a concatenated string of related records.
    'Return:    String variant, or Null if no matches.
    'Arguments: strField = name of field to get results from and concatenate.
    '           strTable = name of a table or query.
    '           strWhere = WHERE clause to choose the right values.
    '           strOrderBy = ORDER BY clause, for sorting the values.
    '           strSeparator = characters to use between the concatenated values.
    'Notes:     1. Use square brackets around field/table names with spaces or odd characters.
    '           2. strField can be a Multi-valued field (A2007 and later), but strOrderBy cannot.
    '           3. Nulls are omitted, zero-length strings (ZLSs) are returned as ZLSs.
    '           4. Returning more than 255 characters to a recordset triggers this Access bug:
    '               http://allenbrowne.com/bug-16.html
    'Source: http://allenbrowne.com/func-concat.html
    Dim RS As DAO.Recordset         'Related records
    Dim rsMV As DAO.Recordset       'Multi-valued field recordset
    Dim strSql As String            'SQL statement
    Dim strOut As String            'Output string to concatenate to.
    Dim lngLen As Long              'Length of string.
    Dim bIsMultiValue As Boolean    'Flag if strField is a multi-valued field.
    
    'Initialize to Null
    ConcatRelated3 = Null
    
    'Build SQL string, and get the records.
    strSql = "SELECT " & strField & " FROM " & strTable
    If strWhere <> vbNullString Then
        strSql = strSql & " WHERE " & strWhere
    End If
    If strOrderBy <> vbNullString Then
        strSql = strSql & " ORDER BY " & strOrderBy
    End If
    Set RS = DBEngine(0)(0).OpenRecordset(strSql, dbOpenDynaset)
    'Determine if the requested field is multi-valued (Type is above 100.)
    bIsMultiValue = (RS(0).Type > 100)
    
    'Loop through the matching records
    Do While Not RS.EOF
        If bIsMultiValue Then
            'For multi-valued field, loop through the values
            Set rsMV = RS(0).Value
            Do While Not rsMV.EOF
                If Not IsNull(rsMV(0)) Then
                    strOut = strOut & rsMV(0) & strSeparator
                End If
                rsMV.MoveNext
            Loop
            Set rsMV = Nothing
        ElseIf Not IsNull(RS(0)) Then
            'NR Specific
            strOut = strOut & "DN " & RS(0) & " " & RS(1) & " z roku " & RS(2) & " v délce " & Round(RS(3), 1) & " m" & strSeparator
        End If
        RS.MoveNext
    Loop
    RS.Close
    
    'Return the string without the trailing separator.
    lngLen = Len(strOut) - Len(strSeparator)
    If lngLen > 0 Then
        ConcatRelated3 = Left(strOut, lngLen)
    End If

Exit_Handler:
    'Clean up
    Set rsMV = Nothing
    Set RS = Nothing
    Exit Function

Err_Handler:
    MsgBox "Error " & Err.Number & ": " & Err.Description, vbExclamation, "ConcatRelated3()"
    Resume Exit_Handler
End Function


