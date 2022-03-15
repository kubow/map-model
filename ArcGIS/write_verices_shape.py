import arcpy
import os
import shutil

#set path and define in/outputs
    myPath = "C:\\_Model\\RUN\\" 
    outfile = open(myPath + "Lines.txt","w")
    Line_Layer = myPath + "obtok_meandr_2.shp" 
#exporting
lCount = 1 
Line_Collection = arcpy.SearchCursor(Line_Layer,"","","","") 
for Line in Line_Collection: 
    outfile.write("Line " + str(lCount) + "n") 
    lCount = lCount + 1 
    lShape = Line.Shape 
    pCount = 1 
    for lPart in lShape: 
    outfile.write("Part " + str(pCount) + "n") 
    pCount = pCount + 1 
    for lPoint in lPart: 
    outfile.write (str(lPoint.X) + " " + str(lPoint.Y) + "n") 
outfile.close 
print "DONE"