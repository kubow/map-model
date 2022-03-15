# Created by Jakub Vajda - last edit 09/2015
# Script used for exporting bookmarks
# from MXD ESRI maps as JPEG pictures or PDFs
import arcpy
import shutil
import os
# Script variables
# - provide path to MXD ESRI map with saved bookmarks
Map = r"C:\_Model\Sustainibility_C_Model.mxd"
# - provide main layer name
LyrName = "Layers"
# - export path as parameter, if argument not passed, using variable
Path = arcpy.GetParameterAsText(0)
if Path == '#' or not Path:
    Path = "C:\\_Model\\Output\\" #default value if unspecified


# - - - Start of Script itslef - - - 
# (Process clear directory - delete - create - os.mkdir(Cesta))
shutil.rmtree(Path, ignore_errors=True)
if not os.path.exists(Path):
    os.makedirs(Path)
mxd = arcpy.mapping.MapDocument(Map)
df = arcpy.mapping.ListDataFrames(mxd, LyrName)[0]
for bkmk in arcpy.mapping.ListBookmarks(mxd, data_frame=df):
    df.extent = bkmk.extent
    outJPG = Path + bkmk.name + ".jpg"
    outPDF = Path + bkmk.name + ".pdf"
    # comment next line if user do not want to export JPG
    arcpy.mapping.ExportToJPEG(mxd, outJPG, df)
    # comment next line if user do not want to export PDF
    arcpy.mapping.ExportToPDF(mxd, outPDF, df, df_export_width=1600,df_export_height=1200)
del mxd
