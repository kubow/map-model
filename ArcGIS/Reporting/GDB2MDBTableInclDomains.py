import os
import string
import logging
import unicodedata
import time

#Working Directory
folder = "C:/DHI/RptTool"
#Final dir
gdb_target = folder + "/Report.mdb"
sFilter = "WU_USEK_VOD_RAD"
#sFilter = "WU_USEK_VOD_RAD/WN_VODOJEM/WN_UZAVER"
sType = ""
#sType = "polyline/point/or leave empty"
templateDB = "ReportEmty.mdb"
#Setting of logger
logging.basicConfig()
logger = logging.getLogger('PY')
logger.setLevel(logging.DEBUG)
formatter = logging.Formatter(fmt='%(asctime)s - %(name)s - %(levelname)s - %(message)s',datefmt='%d.%m.%Y %H:%M:%S')
#Create file handler which logs debug messages
fh = logging.FileHandler(folder + '/Logfile.log')
fh.setLevel(logging.DEBUG)
fh.setFormatter(formatter)
ch = logging.StreamHandler()
ch.setLevel(logging.ERROR)
ch.setFormatter(formatter)
logger.addHandler(fh)
logger.addHandler(ch)

try:
    try:
      import arcpy
      #from arcpy import gp
      #module for decide between v9.3 and 10
      import gp
      env.workspace = ws
    except ImportError:
      import arcgisscripting
      #or set a 9.x flag here
      gp = arcgisscripting.create(9.3)
      if os.path.exists("C:/Program Files (x86)/ArcGIS/ArcToolbox/Toolboxes/") == True:
        gp.AddToolbox("C:/Program Files (x86)/ArcGIS/ArcToolbox/Toolboxes/Conversion Tools.tbx")
        gp.AddToolbox("C:/Program Files (x86)/ArcGIS/ArcToolbox/Toolboxes/Data Management Tools.tbx")
        gp.AddToolbox("C:/Program Files (x86)/ArcGIS/ArcToolbox/Toolboxes/Analysis Tools.tbx")
        environment = '9.3'
      else:
        gp.AddToolbox("C:/Program Files (x86)/ArcGIS/Desktop10.1/ArcToolbox/Toolboxes/Conversion Tools.tbx")
        gp.AddToolbox("C:/Program Files (x86)/ArcGIS/Desktop10.1/ArcToolbox/Toolboxes/Data Management Tools.tbx")
        gp.AddToolbox("C:/Program Files (x86)/ArcGIS/Desktop10.1/ArcToolbox/Toolboxes/Analysis Tools.tbx")
        environment = '10.x'
      #gp.workspace = ws

    if environment == '10.x':
      arcpy.env.overwriteOutput = True
      arcpy.env.transferDomains = True
    else:
      gp.OverWriteOutput = 1
      #transfer domains in 9.3 is not possible

    logger.info('* * * start of a new script * * *')
    #clean target personal MDB (gdb_target)
    if gp.Exists(gdb_target):
        gp.Delete_management(gdb_target)
    runCommand = 'copy ' + folder + '/Templates/' + templateDB + ' ' + gdb_target
    logger.info('copy template personal MDB over ' + gdb_target + '(' + runCommand + ')')
    os.system(runCommand.replace("/", "\\"))
    #create SQL connection to database
    #DRV  = "{Microsoft Access Driver (*.mdb)}"
    #conn = pyodbc.connect("DRIVER=%s;DBQ=%s" % (DRV,gdb_target))
    #curs = conn.cursor()
    f = open("runSQL.txt","w") 
    logger.info('Search for file geodatabases  in (' + folder + ')')
    for (path, dirs, files) in os.walk(folder):
        if ".gdb" not in path.lower():
            gp.workspace = path
            databases = gp.ListWorkspaces("*", "FileGDB")
            for database in databases:
                gp.workspace = database
                #Parameters domain table (name, description, coded values, type)
                logger.info('Search for feature classes in ' + database + '(Filtered by "' + sFilter + '")')
                for fds in gp.ListDatasets("*"):
                    gp.workspace = fds
                    oList = gp.ListFeatureClasses(sFilter, sType)
                    if oList not in (None, ''):
                        for fc in oList:
                            logger.info("Match " + fc + "...preparing to export to " + gdb_target + '/' + fc )
                            if gp.Exists(gdb_target + '/' + fc):
                                gp.Delete_management(gdb_target + '/' + fc)
                            objFC = []
                            gp.workspace = fc
                            nameFC = gdb_target + '/' + fc
                            desc = gp.Describe(fc)
                            fldCnt=1
                            fieldMap = ''
                            domainFLD = []
                            logger.info("Processing " + desc.DataType + " " + desc.CatalogPath + ' ' + " (" + desc.ShapeType + " type)")
                            for fld in desc.Fields:
                                objFLD = []
                                aliasFLD = unicodedata.normalize('NFKD', fld.aliasName).encode('ascii','ignore')
                                aliasFLD = aliasFLD.replace(" ", "_")
                                aliasFLD = aliasFLD.replace(".", "")
                                #Field no.1 - Type: OID/Domain/Subtype/Int/Str..
                                if fld.type not in ('Geometry') and fld.name not in ('GLOBALID'):
                                    objFLD.append(fld.type)
                                    if fldCnt > 1:
                                        fieldMap=fieldMap + '; '
                                    fldCnt+=1
                                    if fld.type == 'OID':
                                        fieldMap=fieldMap + 'IDRef' + ' \"JoinObjectID\"'
                                    else:
                                        fieldMap=fieldMap + aliasFLD + ' \"' + fld.aliasName + '\"'
                                    #TODO subtypes
                                    if fld.domain <> '':
                                        objFLD.append('Domain')
                                    else:
                                        objFLD.append(fld.type)
                                else:
                                     logger.info(fld.name)
                                #Field no.2 - Name in original feature class
                                objFLD.append(fld.name)
                                #Field no.3 - Alias name - data in unicode format, spaces replaced with underscores, dots removed - aliasFLD variable
                                objFLD.append(aliasFLD)
                                #Field no.4 - Name in exported shapefile (domains prefix/10 chars max) / if domain table not exist - reporting
                                if fld.domain <> '':
                                    objFLD.append('d_' + fld.name[:8])
                                    if gp.Exists(gdb_target + '/' + aliasFLD)==False:
                                        domainFLD.append(aliasFLD)
                                        #Exporting domain table to gdb, appending TEXT column, update to Domain.Code - join field (needs to be text)
                                        logger.info("Exporting domain table to " + gdb_target + '/' + aliasFLD + ' - SQL join with same name field in ' + fc)
                                        if environment == '10.x':
                                            print database + ',' + fld.domain + ',' + gdb_target + '/' + aliasFLD + ',Code, Description ('+fld.name+')'
                                            print 'gp.domaintotable('+database+', '+fld.domain+', '+gdb_target + '/' + aliasFLD+', "Code", "Description")'
                                            gp.domaintotable(database, fld.domain, gdb_target + '/' + aliasFLD, "Code", "Description")
                                        else:
                                            print database.replace("\\", "/") + ',' + fld.domain + ',' + gdb_target + '/' + aliasFLD
                                            gp.DomainToTable(database, fld.domain, gdb_target + '/' + aliasFLD, "Code", "Description")
                                        time.sleep(1)
                                        SQL  = "ALTER TABLE " + aliasFLD + " ADD COLUMN text_col TEXT;"
                                        #logger.info('Appending field for connection: '+SQL)
                                        f.write(SQL+'\n')
                                        #curs.execute(SQL)
                                        #conn.commit()
                                        SQL  = "UPDATE " + aliasFLD + " SET " + aliasFLD + ".text_col = " + aliasFLD + ".[Code];"
                                        #logger.info('Preparing values: '+SQL)
                                        f.write(SQL+'\n')
                                        #curs.execute(SQL)
                                        #conn.commit()
                                else:
                                    objFLD.append(fld.name[:10])
                                #Field no.5 - field data type for ArcGIS (Table to Table)
                                if objFLD[0] in ('Date', 'Time'):
                                    objFLD.append("DATE")
                                    fieldMap=fieldMap+' true true false 8 Date 0 0 '
                                elif objFLD[0] in ('Double', 'Single'):
                                    objFLD.append("DOUBLE")
                                    fieldMap = fieldMap + ' true true false 8 Double 0 0 '
                                elif objFLD[0] in ('Long'):
                                    objFLD.append("LONG")
                                    fieldMap = fieldMap + ' true true false 4 Long 0 0 '
                                else:
                                    if fld.type not in ('OID', 'Geometry') and fld.name not in ('GLOBALID'):
                                        objFLD.append("TEXT")
                                        fieldMap=fieldMap + ' true false false 255 Text 0 0 '
                                    elif fld.type == 'OID':
                                        objFLD.append("TEXT")
                                        fieldMap=fieldMap + ' true true false 8 Double 0 0 '
                                objFC.append(objFLD)
                                if fld.type not in ('Geometry') and fld.name not in ('GLOBALID'):
                                    if fld.type == 'OID':
                                        fieldMap = fieldMap + ',First,#,' + desc.CatalogPath + ',' + fld.name + ',-1,-1'
                                    else:
                                        fieldMap = fieldMap + ',First,#,' + desc.CatalogPath + ',' + fld.name + ',-1,-1'
                            #Feature Class variables preparation done - starting Table
                            logger.info('Exporting ' + fc +  ' - original data table to ' + gdb_target + '/' + fc + '_val')
                            gp.TableToTable_conversion(desc.CatalogPath, gdb_target, fc+'_val', "", "", "")
                            #gp.FeatureclassToFeatureclass_conversion(desc.CatalogPath, gdb_target, fc+'_fc', "", "", "")
                            logger.info(fieldMap)
                            logger.info('Exporting ' + desc.CatalogPath +  ' - final data table to ' + gdb_target + '/' + fc + ' (modified by fieldMap)')
                            gp.TableToTable_conversion(desc.CatalogPath, gdb_target, fc, "", fieldMap, "")
                            for domainObj in domainFLD:
                                SQL  = "UPDATE " + domainObj + " INNER JOIN " + fc + " ON " + domainObj + ".text_col = " + fc + "." + domainObj + " SET " + fc + "." + domainObj + " = [" + domainObj + "].[Description];"
                                #logger.info('Updating column domains SQL: '+SQL)
                                #curs.execute(SQL)
                                #conn.commit()
                                f.write(SQL+'\n')
                        logger.info('Finished data table ' + gdb_target + '/' + fc + '')
                        #special SQL for update Subtype in field Subtyp_vodovodniho_radu
                        SQL = "UPDATE Subtyp_vodovodniho_radu INNER JOIN WU_USEK_VOD_RAD ON Subtyp_vodovodniho_radu.text_col = WU_USEK_VOD_RAD.Subtyp_vodovodniho_radu SET WU_USEK_VOD_RAD.Subtyp_vodovodniho_radu = [Subtyp_vodovodniho_radu].[Description]"
                        f.write(SQL+'\n')
                        logger.info('Exported SQL list to ' + folder + '/' + 'RunSQL.txt - linked to ' + gdb_target)
    #rows = curs.fetchall()
    #curs.close()
    #conn.close()
    f.close()
    logger.info('+ + + Script Finished...')
except Exception, e:
    logger.error(e)
