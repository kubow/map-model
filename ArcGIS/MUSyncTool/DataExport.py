import os, sys
import arcpy
import string, unicodedata, time
import logging
import pyodbc
# import sqlite3 - disabled for now - https://docs.python.org/2/library/sqlite3.html

# working Directory setting
folder = os.getcwd()
input_folder = folder+'\\Inputs\\'
output_folder = folder+'\\Outputs\\'
template_folder = folder+'\\Templates\\'
gdb_target=output_folder+'Master.mdb'
# database with export map
comparisonDB = output_folder+'Comparison.mdb'
# other variable settings
GlobalFieldName = 'GLOBAL_'

# load query to restrict selection - from ModelRegistrationTable
arcpy.env.workspace=output_folder+'Model.mdb\\ModelRegister'
if arcpy.Exists(output_folder+'Model.mdb\\ModelRegister'):
    cur = arcpy.SearchCursor(output_folder+'Model.mdb\\ModelRegister')
    for row in cur:
        typeNetwork = row.getValue('Mode').lower()
        modelName = row.getValue('Model')
        queryArea = row.getValue('Area')
        queryBufferArea = row.getValue('BufferArea')
        argument = row.getValue('Argument')
        wholeModelName = typeNetwork+'_'+modelName+'_'+row.getValue("Mdate").strftime('%Y%m%d')
else:
    # logger.log(30, '0 ; Model.mdb is not registered. Please register... Ending script')
    raise ValueError('0 ; Please register Model')

# setting of logger
os.system('title '+os.path.basename(__file__).split('.')[0]+'.py')
logging.basicConfig()
logger = logging.getLogger('PY ; '+os.path.basename(__file__).split('.')[0])
logger.setLevel(logging.DEBUG)
formatter = logging.Formatter(fmt='%(asctime)s ; '+wholeModelName+' ; %(name)s ; %(levelname)s ; %(message)s', datefmt='%d.%m.%Y %H:%M:%S')
fh = logging.FileHandler(folder + '\\Logfile.log')
fh.setLevel(logging.DEBUG)
fh.setFormatter(formatter)
ch = logging.StreamHandler()
ch.setLevel(logging.ERROR)
ch.setFormatter(formatter)
logger.addHandler(fh)
logger.addHandler(ch)
# end of logger setup

#Arcpy environment settings
arcpy.env.overwriteOutput = True
arcpy.env.transferDomains = True

# initial Settings - list of feature classes and corresponding fields
logger.log(10, '0 ; Model is registered. Model name: '+modelName+', mode: '+typeNetwork+', arguments '+str(argument))
db = pyodbc.connect('Driver={Microsoft Access Driver (*.mdb)};Dbq='+comparisonDB+';Uid=;Pwd=;') #db = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source="+comparisonDB+";"
# http://www.easysoft.com/developer/languages/python/pyodbc.html #conn=pyodbc.connect(db)
defFC = []
cursor = db.cursor()

# load list of FC corresponding to type of network chosen
logger.log(10, '0 ; Restricting over limitation string: '+queryArea)
logger.log(10, '0 ; Restricting over buffer area: '+queryBufferArea)
cursor.execute('SELECT * FROM Model_'+typeNetwork.upper()+';')
rows = cursor.fetchall()
for row in rows:
    if row[2].upper() in typeNetwork.upper():
        defFieldFC = []
        defFieldFC.append(row[0])
        defFC.append(defFieldFC)
# conn.close()

# prepare target personal MDB (gdb_target)
if arcpy.Exists(gdb_target):
    arcpy.Delete_management(gdb_target)
arcpy.CreatePersonalGDB_management(output_folder, gdb_target.split('\\')[-1])
# runCommand = 'copy '+templateDB+' '+gdb_target
# logger.log(10, '0 ; copy template personal MDB over '+gdb_target+' ('+runCommand+')')
# os.system(runCommand.replace("/","\\"))
logger.log(10, '0 ; created MASTER database in '+gdb_target)

# start looking for GDB in given directory - some bug appearing https://geonet.esri.com/thread/72686 - coped with that
try:
    for (path, dirs, files) in os.walk(input_folder):
        if ".gdb" not in path.lower():
            arcpy.env.workspace = path
            logger.log(10, '0 ; Searching for file geodatabases (*.GDB) in "'+input_folder+'"')
            for database in arcpy.ListWorkspaces("*", "FileGDB"):
                if database.split('\\')[-1] == 'GIS.gdb':
                    arcpy.env.workspace = database
                    # write main logger categories
                    logger.log(10, '0 ; Found file geodatabase ('+database.split("\\")[-1]+') in "'+input_folder+'"')
                    logger.log(20, '3 ; GIS: Backup GLOBALID (over database: '+database+')')
                    logger.log(20, '4 ; Master: Import selected feature classes from GIS by selected area')
                    logger.log(20, '4 ; Master: Import domain from GIS ('+database+')')
                    for fc in arcpy.ListFeatureClasses():
                        for finTarget in defFC:
                            if finTarget[0] in fc:
                                logger.log(10, '0 ; Searching for feature classes in "'+database+' root directory')
                                arcpy.env.workspace = fc
                                desc=arcpy.Describe(fc)
                                logger.log(10, '0 ; found feature class '+fc+'in "'+database+' (root directory) and skipping...')
                                # processFeatures(fc, GlobalFieldName, desc, database+'\\'+fc, gdb_target+'\\'+fc, cursor, logger)
                                logger.log(10, '0 ; Finished processing feature class '+fc+' in "'+database+' root directory')

                    arcpy.env.workspace=database
                    # start finding FC by matching name from definition table (Comparision.mdb)
                    for fds in arcpy.ListDatasets():
                        logger.log(10, '0 ; Searching dataset "'+fds+'" for feature classes in "'+database)
                        for fc in arcpy.ListFeatureClasses("*","All",fds):
                            for finTarget in defFC:
                                if finTarget[0] in fc:
                                    arcpy.env.workspace = fc
                                    desc = arcpy.Describe(fc)
                                    logger.log(10, '0 ; Found feature class '+finTarget[0]+' in '+database+'\\'+fds+' matching selection of feature classes')
                                    # processFeatures(fc, GlobalFieldName, desc, database+'\\'+fds+'\\'+fc, gdb_target+'\\'+fc, cursor, logger)

                                    # adding new column, calcutating unique ID
                                    logger.log(10, '3 ; Adding '+GlobalFieldName+' column (type TEXT@255) in location: '+database+'\\'+fds+'\\'+fc)
                                    arcpy.AddField_management(fc, GlobalFieldName, "TEXT", "", "", "", GlobalFieldName, "NULLABLE", "NON_REQUIRED")
                                    arcpy.AddField_management(fc, "PVK_OID", "TEXT", 255, "", "", "PVK_OID", "NULLABLE", "NON_REQUIRED")
                                    logger.log(10, '3 ; Added '+GlobalFieldName+' column (type TEXT@255) in location: '+database+'\\'+fds+'\\'+fc)
                                    logger.log(10, '3 ; Calculating column '+GlobalFieldName+' in location: '+database+'\\'+fds+'\\'+fc)
                                    arcpy.CalculateField_management(fc, GlobalFieldName,'!GLOBALID!', "PYTHON")
                                    arcpy.CalculateField_management(fc, "PVK_OID",'!OBJECTID!', "PYTHON")
                                    logger.log(10, '3 ; Calculated column '+GlobalFieldName+' in location: '+database+'\\'+fds+'\\'+fc)

                                    # data export - create layer, select features, export to Master
                                    # performing the Clip by a model buffer - arcpy.Clip_analysis(fc,output_folder+'Model.mdb\\Buffer',gdb_target+'\\'+fc+'_clip')
                                    logger.log(10, '4 ; Preparing artificial layer ('+fc+'_LYR) from '+database+'\\'+fc)
                                    FC_LYR = arcpy.MakeFeatureLayer_management(database+'\\'+fc, fc+'_LYR')
                                    logger.log(10, '4 ; Prepared artificial layer ('+fc+'_LYR) from '+database+'\\'+fc)

                                    # exporting feature classes (By Definition table) to Master database
                                    if 'WD' in typeNetwork.upper():
                                        if fc not in ('WN_CERPSTANICE', 'WN_VODOJEM'):
                                            logger.log(10, '4 ; Selecting records in feature class '+database+'\\'+fc+' by PZone selection('+queryArea+')')
                                            arcpy.SelectLayerByAttribute_management(FC_LYR, "NEW_SELECTION", queryArea)
                                            logger.log(10, '4 ; Selected records in feature class '+database+'\\'+fc+' by PZone selection('+queryArea+')')
                                            if fc == 'WU_USEK_VOD_RAD':
                                                arcpy.SelectLayerByAttribute_management(FC_LYR,"REMOVE_FROM_SELECTION",""""PODTYP" = 7""")
                                            arcpy.FeatureClassToFeatureClass_conversion(FC_LYR, gdb_target, fc, "", "", "")
                                            logger.log(10, '4 ; Exported records in feature class '+database+'\\'+fc+' to Master database '+gdb_target)

                                            logger.log(10, '4 ; Selecting records in feature class '+database+'\\'+fc+' by prepared Buffer in '+output_folder+'Model.mdb\\B_mw_Pipe')
                                            arcpy.SelectLayerByLocation_management(FC_LYR,"INTERSECT",output_folder+'Model.mdb\\B_mw_Pipe',"#","NEW_SELECTION")
                                            arcpy.SelectLayerByAttribute_management(FC_LYR,"SUBSET_SELECTION",queryBufferArea)
                                            if fc == 'WU_USEK_VOD_RAD':
                                                arcpy.SelectLayerByAttribute_management(FC_LYR,"REMOVE_FROM_SELECTION",""""PODTYP" = 7""")
                                            logger.log(10, '4 ; Selected records in feature class '+database+'\\'+fc+' by prepared Buffer in '+output_folder+'Model.mdb\\B_mw_Pipe')
                                            #arcpy.FeatureClassToFeatureClass_conversion (FC_LYR, output_folder, str(fc)+'_P999.shp', "", "", "")
                                            arcpy.Append_management(FC_LYR, gdb_target + '\\' + fc, "NO_TEST", "", "")
                                            logger.log(10, '4 ; Exported PZone = 9999 from feature class '+database+'\\'+fc+' to Master database '+gdb_target)
                                        else:
                                            logger.log(10, '4 ; Clipping records '+database+'\\'+fc+' by prepared buffer')
                                            arcpy.Clip_analysis(fc, output_folder+'Model.mdb\\B_mw_Pipe',gdb_target+'\\'+fc)
                                            logger.log(10, '4 ; Clipped records to feature class '+gdb_target+'\\'+fc)
                                    elif 'CS' in typeNetwork.upper():
                                        if 'SU_USEK_STOKA' in fc:
                                            logger.log(10, '4 ; Selecting records in feature class '+database+'\\'+fc+' by PZone selection')
                                            arcpy.SelectLayerByAttribute_management(FC_LYR, "NEW_SELECTION", queryArea)
                                            logger.log(10, '4 ; Selected records in feature class '+database+'\\'+fc+' by PZone selection')
                                            arcpy.FeatureClassToFeatureClass_conversion(FC_LYR, gdb_target, fc, "", "", "")
                                            logger.log(10, '4 ; Exported records in feature class '+database+'\\'+fc+' to Master database '+gdb_target)

                                            logger.log(10, '4 ; Selecting records in feature class '+database+'\\'+fc+' by buffer location')
                                            arcpy.SelectLayerByAttribute_management(FC_LYR, "NEW_SELECTION", queryBufferArea)
                                            arcpy.SelectLayerByLocation_management(FC_LYR,"INTERSECT",output_folder+'Model.mdb\\B_msm_Link',"#","SUBSET_SELECTION")
                                            logger.log(10, '4 ; Selected records in feature class '+database+'\\'+fc+' by prepared Buffer')
                                            arcpy.Append_management(FC_LYR, gdb_target + '\\' + fc, "NO_TEST", "", "")
                                            logger.log(10, '4 ; Exported PZone = 9999 records in feature class '+database+'\\'+fc+' to Master database '+gdb_target)
                                        elif 'SN_VZTBOD' in fc:
                                            logger.log(10, '4 ; Clipping records '+database+'\\'+fc+' by prepared buffer ()')
                                            arcpy.SelectLayerByAttribute_management(FC_LYR, "NEW_SELECTION", "ID_PRIPOJKA IS NULL")
                                            arcpy.Clip_analysis(FC_LYR, output_folder+'Model.mdb\\B_msm_Link',gdb_target+'\\'+fc)
                                            logger.log(10, '4 ; Clipped records to feature class '+gdb_target+'\\'+fc)
                                        else:
                                            logger.log(10, '4 ; Clipping records '+database+'\\'+fc+' by prepared buffer')
                                            arcpy.Clip_analysis(fc, output_folder+'Model.mdb\\B_msm_Link',gdb_target+'\\'+fc)
                                            logger.log(10, '4 ; Clipped records to feature class '+gdb_target+'\\'+fc)

                                    #Start exporting Domains to tables
                                    logger.log(10, '4 ; Processing domains in '+desc.DataType+' '+desc.CatalogPath+' '+' ('+desc.ShapeType+' type)')
                                    cursor.execute('SELECT * FROM Domains')
                                    rows = cursor.fetchall()
                                    for fld in desc.Fields:
                                        for row in rows:
                                            if fld.domain != '' and fld.domain == row[0]:
                                                arcpy.DomainToTable_management(database, fld.domain, gdb_target+'\\'+fld.domain, "Code", "Description")
                                                logger.log(10, '4 ; Exported '+fld.domain+' domain table to '+gdb_target+'\\'+fld.domain)
                                    logger.log(10, '4 ; Finished processing domains for Feature class ' + database+'\\'+fds+'\\'+fc)

                                    # inserting columns
                                    logger.log(10, '4 ; Inserting columns to '+gdb_target + '\\' + fc)
                                    cursor.execute("SELECT * FROM FC_Def WHERE FC_Name = ?", fc)
                                    rows = cursor.fetchall()
                                    arcpy.AddField_management(gdb_target + '\\' + fc, "Status", "SHORT", "", "", "", "","NULLABLE", "NON_REQUIRED", "" )
                                    arcpy.AddField_management(gdb_target + '\\' + fc, "CYear", "SHORT", "", "", "", "","NULLABLE", "NON_REQUIRED", "" )
                                    for row in rows:
                                        if row[8] is not None:
                                            arcpy.AddField_management(gdb_target + '\\' + fc,row[8]+'_Ch', "SHORT", "", "", "", "","NULLABLE", "NON_REQUIRED", "" )
                                    logger.log(10, '4 ; Columns inserted to '+gdb_target + '\\' + fc)

                                    logger.log(10, '0 ; Finished searching for feature classes in "'+database+' (dataset: '+fds+')')
                                    arcpy.env.workspace = database
                                    

except arcpy.ExecuteError:
    logger.log(40, str(arcpy.GetMessages(2)).replace('\n', ' '))
    #logger.error(command.CommandText) or str(sys.exc_info()[2])

except Exception as ex:
    logger.log(40, ex.args[0].replace('\n', ' '))
    #raw_input("Press enter to continue")
    #os.system("pause")

#Determine if any feature classes missing
cursor.close()
arcpy.env.workspace = gdb_target
for ifExist in defFC:
    if arcpy.Exists(gdb_target+'\\'+str(ifExist[0])):
        logger.log(10, '0 ; Feature class ' + str(ifExist[0]) + ' found in '+gdb_target)
        # arcpy.MakeFeatureLayer_management (gdb_target+'\\'+str(ifExist)+'_clip', str(ifExist))
        # arcpy.SelectLayerByAttribute_management (str(ifExist), "NEW_SELECTION", queryStr)
    else:
        logger.log(30, '0 ; Missing feature class ' + str(ifExist[0]) + ' in '+gdb_target)

