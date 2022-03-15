Attribute VB_Name = "BatchExportMXDToPDF"
Public Sub BatchExportMXDToPDF()

' Tool:       Batch export MXD to PDF
' Purpose:    Saves all MXDs in the selected directory to PDFs in the selected output folder
' Author:     Nico Burgerhart (nicoburgerhart@hotmail.com)
' Date:       10 Jan. 2007

' Changes:
' 20070131    Embed Document Fonts = TRUE, Convert Marker Symbols to Polygons = TRUE
' 20070212    User can choose settings for Embed Document Fonts and Convert Marker Symbols to Polygons options

  Dim pMxDoc As IMxDocument
  Dim pMap As IMap
  Dim pGxDialog As IGxDialog
  Dim pGxObjectFilter As IGxObjectFilter
  Dim anythingSelected As Boolean
  Dim pGxMaps As IEnumGxObject
  Dim pGxMap As IGxMap
  Dim pGxFolders As IEnumGxObject
  Dim pGxFolder As IGxObject
  Dim strStartingLocation As String
  Dim lngOutputResolution As Long
  Dim lngMXDCount As Long
  Dim sFullPathName As String
  Dim response
  Dim pGxObject As IGxObject
  Dim pGxMapPageLayout As IGxMapPageLayout
  Dim pPageLayout As IPageLayout
  Dim blnEmbedFonts As Boolean ' CHANGE 20070212
  Dim blnPolygonizeMarkers As Boolean ' CHANGE 20070212

 
' document, focusmap
  Set pMxDoc = ThisDocument
  Set pMap = pMxDoc.FocusMap
  
' input mxds
  Set pGxObjectFilter = New GxFilterMaps
  Set pGxDialog = New GxDialog
  With pGxDialog
    .Title = "Select input MXDs"
    .AllowMultiSelect = True
  End With
  Set pGxDialog.ObjectFilter = pGxObjectFilter
  anythingSelected = pGxDialog.DoModalOpen(Application.hWnd, pGxMaps)
  If Not anythingSelected Then
    MsgBox "Cancel"
    Exit Sub
  End If
  
' starting location, name
  strStartingLocation = pGxDialog.FinalLocation.Parent.Name
  
' output folder
  Set pGxObjectFilter = New GxFilterBasicTypes
  Set pGxDialog = New GxDialog
  With pGxDialog
    .Title = "Select output folder"
    .AllowMultiSelect = False
    .StartingLocation = strStartingLocation
  End With
  Set pGxDialog.ObjectFilter = pGxObjectFilter
  anythingSelected = pGxDialog.DoModalOpen(Application.hWnd, pGxFolders)
  
  If anythingSelected Then
    Set pGxFolder = pGxFolders.Next
  Else
    MsgBox "Cancel"
    Exit Sub
  End If

' output resolution
  Do
    response = InputBox("Output resolution:")
    If response = "" Then
      MsgBox "Cancel"
      Exit Sub
    End If
    If Not IsNumeric(response) Then
      MsgBox "Output resolution must be a number", vbExclamation
    End If
  Loop Until IsNumeric(response)
  lngOutputResolution = CLng(response)

' CHANGE 20070212
' Embed Document Fonts option
  If vbYes = MsgBox("Embed Document Fonts?", vbYesNo + vbQuestion) Then blnEmbedFonts = True
  
' CHANGE 20070212
' Convert Marker Symbols to Polygons option
  If vbYes = MsgBox("Convert Marker Symbols to Polygons?", vbYesNo + vbQuestion) Then blnPolygonizeMarkers = True

' MXD count
  pGxMaps.Reset
  Set pGxMap = pGxMaps.Next
  Do Until pGxMap Is Nothing
    lngMXDCount = lngMXDCount + 1
    Set pGxMap = pGxMaps.Next
  Loop
  If lngMXDCount = 0 Then Exit Sub
  
' progress bar
  With Application.StatusBar.ProgressBar
    .Message = "Exporting MXD to PDF..."
    .MinRange = 0
    .MaxRange = lngMXDCount
    .StepValue = 1
    .Show
  End With
  
' loop MXDs
  pGxMaps.Reset
  Set pGxMap = pGxMaps.Next
  Do Until pGxMap Is Nothing
      
  ' page layout
    Set pGxMapPageLayout = pGxMap
    Set pPageLayout = pGxMapPageLayout.PageLayout

  ' output name
    Set pGxObject = pGxMap
    sFullPathName = pGxFolder.FullName & "\" & pGxObject.BaseName & ".pdf"
    
  ' export
    If PDFExists(sFullPathName) = True Then
      response = MsgBox(sFullPathName & " already exists. Replace it?", vbYesNo)
      If response = vbYes Then
        CreatePDF pPageLayout, sFullPathName, lngOutputResolution, blnEmbedFonts, blnPolygonizeMarkers
      End If
    Else
      CreatePDF pPageLayout, sFullPathName, lngOutputResolution, blnEmbedFonts, blnPolygonizeMarkers
    End If
  
  ' next MXD
    Application.StatusBar.ProgressBar.Step
    Set pGxMap = pGxMaps.Next
  
  Loop

  ' hide progressbar
  Application.StatusBar.ProgressBar.Hide

End Sub

Private Function PDFExists(sFullPathName As String) As Boolean
  
  Dim MyFile
 
  MyFile = Dir(sFullPathName)
  If MyFile = "" Then
    PDFExists = False
  Else
    PDFExists = True
  End If
  
End Function

Private Sub CreatePDF( _
  pPageLayout As IPageLayout, _
  sFullPathName As String, _
  lngOutputResolution As Long, _
  blnEmbedFonts As Boolean, _
  blnPolygonizeMarkers As Boolean)

  Dim pExporter As IExport
  Dim pExportPDF As IExportPDF
  Dim pExportVectorOptions As IExportVectorOptions ' CHANGE 20070131
  Dim pPixelEnv As IEnvelope
  Dim tExpRect As tagRECT
  Dim hdc As Long
  Dim pAV As IActiveView
  
' pixel envelope
  Set pPixelEnv = New Envelope
  pPixelEnv.PutCoords _
    0, _
    0, _
    lngOutputResolution * PageExtent(pPageLayout).UpperRight.X, _
    lngOutputResolution * PageExtent(pPageLayout).UpperRight.Y
  
  
' exporter object
  Set pExporter = New ExportPDF
  
  With pExporter
    .PixelBounds = pPixelEnv
    .Resolution = lngOutputResolution
    .ExportFileName = sFullPathName
  End With
  
' CHANGE 20070131: Embed Document Fonts option
  Set pExportPDF = pExporter
  pExportPDF.EmbedFonts = blnEmbedFonts
  
' CHANGE 20070131: Convert Marker Symbols to Polygons option
  Set pExportVectorOptions = pExporter
  pExportVectorOptions.PolygonizeMarkers = blnPolygonizeMarkers
  
' device coordinates origin is upper left, ypositive is down
  With tExpRect
    .Left = pExporter.PixelBounds.LowerLeft.X
    .bottom = pExporter.PixelBounds.UpperRight.Y
    .Right = pExporter.PixelBounds.UpperRight.X
    .Top = pExporter.PixelBounds.LowerLeft.Y
  End With
  
' export
  hdc = pExporter.StartExporting
    Set pAV = pPageLayout
    pAV.Output hdc, lngOutputResolution, tExpRect, Nothing, Nothing
    DoEvents
  pExporter.FinishExporting

End Sub

Private Function PageExtent(pPageLayout As IPageLayout) As IEnvelope
    Dim dWidth As Double, dHeight As Double
    pPageLayout.Page.QuerySize dWidth, dHeight
    Dim pEnv As IEnvelope
    Set pEnv = New Envelope
    pEnv.PutCoords 0#, 0#, dWidth, dHeight
    Set PageExtent = pEnv
End Function
