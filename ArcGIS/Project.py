# Name: Project.py

# Description: Project all feature classes in a geodatabase
# Requirements: os module

# Import system modules
import arcpy
import os

# Set environment settings
arcpy.env.workspace = "C:/_Model/_Sklad/QGC_Master_Database.gdb"
arcpy.env.overwriteOutput = True

# Set local variables
outWorkspace = "C:/_Model/_Sklad/QGC_Master_WGS_84.gdb "

try:
    # Use ListFeatureClasses to generate a list of inputs 
    for infc in arcpy.ListFeatureClasses():
    
        # Determine if the input has a defined coordinate system, can't project it if it does not
        dsc = arcpy.Describe(infc)
    
        if dsc.spatialReference.Name == "GCS_GDA_1994":
            print ('skipped this fc due to undefined coordinate system: ' + infc)
        else:
            # Determine the new output feature class path and name
            outfc = os.path.join(outWorkspace, infc)
            
            # Set output coordinate system
            outCS = arcpy.SpatialReference('GCS_WGS_1984')
            
            # run project tool
            arcpy.Project_management(infc, outfc, outCS)
            
            # check messages
            print(arcpy.GetMessages())
            
except arcpy.ExecuteError:
    print(arcpy.GetMessages(2))
    
except Exception as ex:
    print(ex.args[0])
raw_input("Press enter to continue")
#os.system("pause")