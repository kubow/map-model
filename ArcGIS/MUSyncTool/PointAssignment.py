# coding=windows-1250
import arcpy
import numpy
import logging
import os

folder = os.getcwd()
output_folder = folder+'\\Outputs\\'
output_database = output_folder+'Master.mdb'

# Arcpy environment settings
arcpy.env.overwriteOutput=True
arcpy.env.transferDomains=True

# InFc  = arcpy.GetParameterAsText(0) # input feature class
InFc = output_database+'\\WU_USEK_VOD_PRIPOJKA'
OutFc = output_database+'\\WU_USEK_VOD_PRIPOJKA_point' # output feature class
InCIS = folder+'\\Inputs\\PVK_MM.gdb\\xb_mm'
OutCIS = output_database+'\\XB_MM'

# load query to restrict selection - from ModelRegistrationTable
arcpy.env.workspace=output_folder+'Model.mdb\\ModelRegister'
if arcpy.Exists(output_folder+'Model.mdb\\ModelRegister'):
    cur = arcpy.SearchCursor(output_folder+'Model.mdb\\ModelRegister')
    for row in cur:
        typeNetwork = row.getValue('Mode').lower()
        modelName = row.getValue('Model')
        queryArea = row.getValue('Area')
        # queryBufferArea = row.getValue('BufferArea')
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


# 0 - triangles -=- mw_Junctions - closest on line (http://help.arcgis.com/en/arcgisdesktop/10.0/help/index.html#//003m00000007000000.htm)
# 1 - xb_mm -=- many triangles
# 2 - select xb_mm(id_pipe) = triangle(id_pipe)
# 3 - choose only closest one

try:
    mode = arcpy.GetParameter(0)
    logger.log(10, '0 ; Model is registered. Model name: '+modelName+', mode: '+typeNetwork+', arguments '+str(argument))
    if 'Comparison' in mode:
        arcpy.env.workspace = output_database
        # variables for fields
        fldMap = arcpy.FieldMappings()

        if 'WD' in typeNetwork.upper():
            logger.log(20, '4 ; CIS Prepare (' + OutCIS + ')')
            dem_lyr = arcpy.MakeFeatureLayer_management(InCIS, 'dem_lyr')

            # 1 / prepare OutCIS to import to DemAlloc
            # 1a / fist prepare select query over pressure zones
            logger.log(10, '4 ; Starting '+OutCIS+' preparation')
            if 'OR' in queryArea:
                defAreas = queryArea.split(' OR ')
                cntAreas = 1
                for regArea in defAreas:
                    if cntAreas < 2:
                        queryCIS = 'ID_TLAK_PASMO = '+regArea.split('=')[-1].strip()
                        cntAreas += 1
                    else:
                        queryCIS = queryCIS + ' OR ID_TLAK_PASMO = '+regArea.split('=')[-1].strip()
                        cntAreas += 1
            elif '=' in queryArea:
                queryCIS = 'ID_TLAK_PASMO = '+queryArea.split('=')[-1].strip()
            else:
                logger.log(30, '0 ; Not proper restriction query - '+queryArea)
                raise ValueError('0 ; Not proper restriction query - '+queryArea)

            # 1b / then select points passing over water (transfer points)
            arcpy.SelectLayerByLocation_management(in_layer=dem_lyr, overlap_type="INTERSECT", select_features=output_folder+'\\Model.mdb\\B_mw_Pipe', search_distance="", selection_type="NEW_SELECTION")
            arcpy.SelectLayerByAttribute_management(dem_lyr, "SUBSET_SELECTION", "MP_EVNUM1 = 300816 AND ID_TLAK_PASMO Is Null")

            # 1c / append demanders to selection
            # arcpy.SelectLayerByAttribute_management(dem_lyr, "NEW_SELECTION","CMPT_NAME = 'Vodné'") - is the same as
            arcpy.SelectLayerByAttribute_management(dem_lyr, "ADD_TO_SELECTION", queryCIS)

            # 1d / final transfer
            arcpy.FeatureClassToFeatureClass_conversion(dem_lyr, output_database, OutCIS.split('\\')[-1], "", "", "")
            logger.log(10, '4 ; '+OutCIS+' exported')

            # 2 / prepare OutCIS_conn intersecting with connections
            InFcDes = arcpy.Describe(InFc)
            arrFields=['OID@', 'SHAPE@', 'C_PASMO', 'ID_RAD', 'MIGID', 'REFERENCEID']
            fromFields = ['OID@', 'SHAPE@', 'C_PASMO', 'ID_RAD', 'MIGID']
            # Spatial reference of input feature class
            SR = arcpy.Describe(InFc).spatialReference

            # 2b / prepare connecting lines in 2d form
            logger.log(10, '4 ; Creating Polyline Feature class '+InFc+'_2D with no Z values')
            arcpy.CreateFeatureclass_management(output_database, InFc.split('\\')[-1]+'_2D', "POLYLINE", '', 'DISABLED', 'DISABLED', SR)
            logger.log(10, '4 ; Feature class '+OutFc.split('\\')[-1]+'_2D in path '+output_database+' created')

            logger.log(10, '4 ; Appending fields :' + str(arrFields)+' to new feature layer ' + OutFc)
            # comments for future purposes
            # fieldMap = fldMap.getFieldMap(InCIS)
            InFields = arcpy.ListFields(InFc)
            # fldMap_type = arcpy.FieldMap()
            for field in InFields:
                # 2D polyline layer fields prepare
                if field.name not in ('Shape', 'OBJECTID', 'Shape_Length', 'GLOBALID'):
                    arcpy.AddField_management(InFc.split('\\')[-1]+'_2D', field.name, field.type, field.precision, field.scale, field.length, field.aliasName, field.isNullable)
            # fldMap.addTable(OutFc)
            # fldMap.addFieldMap(fldMap_type)
            logger.log(10, '4 ; Fields:' + str(arrFields) + '+ Reference ID and JunctionID appended to new feature layer ' + OutFc)

            InFc_diss = output_database+'\\Connections_Dissolved'
            arcpy.Append_management(InFc, InFc+'_2D', "NO_TEST", "#", "#")
            arcpy.Dissolve_management(InFc+'_2D', InFc_diss,"ID_RAD","#","SINGLE_PART","DISSOLVE_LINES")

            # for future puprposes
            # logger.log(10, '4 ; Transferring Connection line start/end points to new feature layer : ' + OutFc)
            # cursor = arcpy.da.InsertCursor(OutFc, arrFields)
            # i = 0
            # # row 87 - changed InFc to InFc_diss
            # with arcpy.da.SearchCursor(InFc_diss, fromFields) as c:
            #     for row in c:
            #         cursor.insertRow((row[0], row[1].firstPoint, row[2], row[3], row[4], row[0]))
            #         cursor.insertRow((row[0], row[1].lastPoint, row[2], row[3], row[4], row[0]))
            #         # for i in range(len(c.fields)-1):
            #         #         artRow.append(c[i])
            #         i += 2
            # logger.log(10, '4 ; Transferred total of '+str(i)+' points to new feature layer : ' + OutFc)

            # 2c / intersect 2d connections with pipes
            pipes_lyr = output_database+'\\WU_USEK_VOD_RAD'
            pipes_cross_conn = output_database+'\\Connections_Pipes'

            logger.log(10, '4 ; Starting intersect Connections : '+OutFc+' with Pipes line layer '+pipes_lyr)
            arcpy.Intersect_analysis([pipes_lyr, InFc_diss], pipes_cross_conn, "ALL", "0.01", "POINT")
            # arcpy.Intersect_analysis([pipes_lyr, OutFc], pipes_cross_conn, "ALL", "", "POINT")
            logger.log(10, '4 ; Finished intersect : '+OutFc+' with Pipe lines '+pipes_lyr+' transferred to '+pipes_cross_conn)
            arcpy.AddField_management(pipes_cross_conn, 'X', "DOUBLE", "", "", "", 'X', "")
            arcpy.AddField_management(pipes_cross_conn, 'Y', "DOUBLE", "", "", "", 'Y', "")
            arcpy.CalculateField_management(pipes_cross_conn, "X", "!Shape.Centroid.X!", "PYTHON_9.3", "#")
            arcpy.CalculateField_management(pipes_cross_conn, "Y", "!Shape.Centroid.Y!", "PYTHON_9.3", "#")
            logger.log(10, '4 ; Added and calculated X, Y columns to '+pipes_cross_conn)

            arcpy.SelectLayerByAttribute_management(dem_lyr,"NEW_SELECTION","CMPT_NAME = 'Vodné'")

            # logger.log(10, '4 ; Buffer create : '+OutCIS+'_buffer from '+InCIS+' (CMPT_NAME = "Vodné") clipped by'+output_folder+'\\Model.mdb\\B_mw_Pipe')
            # arcpy.SpatialJoin_analysis(InCIS,OutFc,OutCIS,"JOIN_ONE_TO_ONE","KEEP_ALL",fldMap,"CLOSEST","#","#")
            # arcpy.Clip_analysis(dem_lyr,output_folder+'\\Model.mdb\\B_mw_Pipe',OutCIS+'_buffer')
            # logger.log(10, '4 ; Buffer created : '+OutFc+'_buffer from '+InCIS+' clipped by'+output_folder+'\\Model.mdb\\B_mw_Pipe')

            logger.log(10, '4 ; Starting intersect : '+OutFc+' with point layer '+InCIS+' transfer to '+OutCIS+'_conn')
            arcpy.Intersect_analysis([InCIS, InFc_diss], OutCIS+'_conn', "ALL", "0.01", "POINT")
            # arcpy.SpatialJoin_analysis(InCIS, InFc_diss, OutCIS, "JOIN_ONE_TO_ONE", "KEEP_ALL", '', "CLOSEST", '', "Dist")
            logger.log(10, '4 ; Finished intersect : '+OutFc+' with point layer '+InCIS+' transferred to '+OutCIS)

            arcpy.AddField_management(OutCIS+'_conn', 'X', "DOUBLE", "", "", "", 'X', "")
            arcpy.AddField_management(OutCIS+'_conn', 'Y', "DOUBLE", "", "", "", 'Y', "")
            arcpy.AddField_management(OutCIS+'_conn', 'JunctionID', "TEXT", "#", "#", "40", "#", "NULLABLE","NON_REQUIRED","#")
            arcpy.AddField_management(OutCIS+'_conn', 'Select', "DOUBLE", "", "", "", 'SELECT', "")
            arcpy.CalculateField_management(OutCIS+'_conn', "X", "!Shape.Centroid.X!", "PYTHON_9.3", "#")
            arcpy.CalculateField_management(OutCIS+'_conn', "Y", "!Shape.Centroid.Y!", "PYTHON_9.3", "#")
            logger.log(10, '4 ; Added and calculated X, Y columns to '+OutCIS+'_conn')

        elif 'CS' in typeNetwork.upper():
            point = output_database+'\\SN_VZTBOD'
            point1 = output_database+'\\SN_UZEL'
            shaft = output_database+'\\SP_KANALOBJEKT'
            pipes_lyr = output_database+'\\SU_USEK_STOKA'

            # 1/ clear all points which are not intersecting  with links and objects
            # 1a/ first for SN_VZTBOD
            logger.log(10, '4 ; Starting transfer SN_VZTBOD intersecting with links and shafts to SN_VZTBOD_fin')
            point_lyr = arcpy.MakeFeatureLayer_management(point, 'point_lyr')
            arcpy.SelectLayerByLocation_management(in_layer=point_lyr, overlap_type="WITHIN_A_DISTANCE", select_features=pipes_lyr, search_distance="0.1 Meters", selection_type="NEW_SELECTION")
            arcpy.SelectLayerByLocation_management(in_layer=point_lyr, overlap_type="INTERSECT", select_features=shaft, search_distance="", selection_type="ADD_TO_SELECTION")
            arcpy.FeatureClassToFeatureClass_conversion(point_lyr, output_database, "SN_VZTBOD_fin", "", "", "")
            logger.log(10, '4 ; Finished transfer SN_VZTBOD intersecting with links and shafts to SN_VZTBOD_fin')

            # 1b/ then for SN_UZEL
            logger.log(10, '4 ; Starting transfer SN_UZEL intersecting with links and shafts to SN_UZEL_fin')
            point1_lyr = arcpy.MakeFeatureLayer_management(point1, 'point1_lyr')
            arcpy.SelectLayerByLocation_management(in_layer=point1_lyr, overlap_type="WITHIN_A_DISTANCE", select_features=pipes_lyr, search_distance="0.1 Meters", selection_type="NEW_SELECTION")
            #arcpy.SelectLayerByLocation_management(in_layer=point1_lyr, overlap_type="INTERSECT", select_features=shaft, search_distance="", selection_type="ADD_TO_SELECTION")
            arcpy.FeatureClassToFeatureClass_conversion(point1_lyr, output_database, "SN_UZEL_fin", "", "", "")
            logger.log(10, '4 ; Finished transfer SN_UZEL intersecting with links and shafts to SN_UZEL_fin')

            # 2/ create OutCIS

            # arcpy.SelectLayerByAttribute_management(shaft_lyr,"NEW_SELECTION",queryBufferArea)

            # arcpy.SpatialJoin_analysis(InCIS, shaft_lyr, output_database+'\\XB_MM_UZEL', "JOIN_ONE_TO_ONE", "KEEP_ALL", '', "CLOSEST", '', "DistUzel")
            # arcpy.SpatialJoin_analysis(output_database+'\\XB_MM_UZEL', point_lyr, OutCIS, "JOIN_ONE_TO_ONE", "KEEP_ALL", '', "CLOSEST", '', "DistVztbod")

            arcpy.SpatialJoin_analysis(InCIS, point_lyr, OutCIS, "JOIN_ONE_TO_ONE", "KEEP_ALL", '', "CLOSEST", '', "DistVztbod")

    elif 'Update' in mode:
        # 1/ - remove duplicated values of measurement points
        MM_LYR_C = arcpy.MakeFeatureLayer_management(OutCIS+'_conn', 'MM_LYR_C')
        arcpy.SelectLayerByAttribute_management(in_layer_or_view=MM_LYR_C, selection_type="NEW_SELECTION", where_clause="[Select_] =  1")
        arcpy.DeleteFeatures_management(in_features=MM_LYR_C)

        # 2/ - append remaining measurement points from xb_mm
        MM_LYR = arcpy.MakeFeatureLayer_management(OutCIS, 'MM_LYR')
        # select all differing from connected measurement points
        # arcpy.SelectLayerByLocation_management(in_layer=MM_LYR_buffer, overlap_type="INTERSECT", select_features=OutCIS, search_distance="", selection_type="NEW_SELECTION", invert_spatial_relationship="INVERT")
        arcpy.SelectLayerByLocation_management(in_layer=MM_LYR, overlap_type="INTERSECT", select_features=OutCIS+'_conn', search_distance="", selection_type="NEW_SELECTION")
        arcpy.SelectLayerByLocation_management(in_layer=MM_LYR, overlap_type="INTERSECT", select_features=OutCIS+'_conn', search_distance="", selection_type="SWITCH_SELECTION")
        arcpy.Append_management(MM_LYR, OutCIS+'_conn', "NO_TEST", "#", "#")

        # 3/ - connect Measurement points where is no information about joined data
        arcpy.SelectLayerByAttribute_management(MM_LYR_C,"NEW_SELECTION","[ID_RAD] IS NULL")
        # arcpy.Select_analysis("MM_LYR", "C:/DHI/MU_GIS_Update/Outputs/Master.mdb/XB_MM_Select","[ID_RAD] IS NULL")

        if 'WD' in typeNetwork.upper():
            joined_pts = 'mw_Junction'
        elif 'CS' in typeNetwork.upper():
            joined_pts = 'msm_Node'

        logger.log(10, '4 ; Layer : '+OutCIS+'_conn selected by query "[ID_RAD] IS NULL"')
        arcpy.SpatialJoin_analysis(OutCIS+'_conn', output_folder+'Model.mdb\\mu_Geometry\\'+joined_pts, OutCIS+'_selJoin', "JOIN_ONE_TO_ONE", "KEEP_ALL", '', "CLOSEST", '', "Dist")
        logger.log(10, '4 ; Layer : '+OutCIS+'_conn spatially joined with '+joined_pts+' to '+OutCIS+'_selJoin')

        # 4/ - close pipes which are under feature layer of closing points - only for mode water distribution
        if 'WD' in typeNetwork.upper():
            # prepare layers
            pipes_close = arcpy.MakeFeatureLayer_management(output_folder+'Model.mdb\\mw_Pipe', 'pipes_close')
            arcpy.MakeFeatureLayer_management(output_database+'\\WN_UZAVER', 'closure_pts')
            closed = arcpy.mapping.Layer('closure_pts')
            closed.name = 'closing_pts'
            closed.definitionQuery = '[PODTYP] = 4 OR [PODTYP] = 6'
            # start selecting records and calculating of closed ones
            arcpy.SelectLayerByLocation_management(in_layer=pipes_close, overlap_type="INTERSECT", select_features=closed, search_distance="", selection_type="NEW_SELECTION")
            arcpy.CalculateField_management(in_table=pipes_close, field="StatusNo", expression="1", expression_type="VB", code_block="")
            # clean after procedure
            del closed

            # 5 / prepare junction layer to master database
            arcpy.FeatureClassToFeatureClass_conversion(output_folder+'\\Model.mdb\\mu_Geometry\\mw_Junction', output_database, 'mw_Junction', "", "", "")
            arcpy.AddField_management(output_database+'\\mw_Junction', 'X', "DOUBLE", "", "", "", 'X', "")
            arcpy.AddField_management(output_database+'\\mw_Junction', 'Y', "DOUBLE", "", "", "", 'Y', "")
            arcpy.CalculateField_management(output_database+'\\mw_Junction', "X", "!Shape.Centroid.X!", "PYTHON_9.3", "#")
            arcpy.CalculateField_management(output_database+'\\mw_Junction', "Y", "!Shape.Centroid.Y!", "PYTHON_9.3", "#")

            # 5/ - intersect pies and junctions
            logger.log(10, '4 ; Starting intersect pipes with junctions')
            arcpy.Intersect_analysis([output_folder+'Model.mdb\\mu_Geometry\\mw_Junction', output_folder+'Model.mdb\\mu_Geometry\\mw_Pipe'], output_database+'\\mw_JuncPipes', "ALL", "0.01", "POINT")
            # arcpy.Intersect_analysis([pipes_lyr, OutFc], pipes_cross_conn, "ALL", "", "POINT")
            logger.log(10, '4 ; Finished intersect pipes with junctions')

    else:
        logger.log(30, '0 ; Not submitted proper parameters')
        raise ValueError('0 ; Please submit Comparison/Update parameter to point assignment script...')


except arcpy.ExecuteError:
    logger.error(str(arcpy.GetMessages(2).replace('\n', ' ')))
    #logger.error(command.CommandText) or str(sys.exc_info()[2])

except Exception as ex:
    logger.error(ex.args[0].replace('\n', ' '))
    # raw_input("Press enter to continue")
    # os.system("pause")
