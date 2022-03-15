import os
import sys
import arcpy
import logging


class LicenseError(Exception):
    pass

# working Directory setting
folder = os.getcwd()
input_folder = folder+'\\Inputs\\'
output_folder = folder+'\\Outputs\\'
input_raster = input_folder+'dtm1m.tiff'
junctions = output_folder+"Model.mdb\\mu_Geometry\\mw_Junction"

# setting of logger
logging.basicConfig()
logger = logging.getLogger('PY - '+os.path.basename(__file__).split('.')[0])
logger.setLevel(logging.DEBUG)
formatter = logging.Formatter(fmt='%(asctime)s - %(name)s - %(levelname)s - %(message)s', datefmt='%d.%m.%Y %H:%M:%S')
fh = logging.FileHandler(output_folder + 'Logfile.log')
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
if arcpy.CheckExtension("Spatial") == 'Available':
    arcpy.CheckOutExtension("Spatial")
else:
    raise LicenseError
buffer_found = False

try:
    for (path, dirs, files) in os.walk(input_folder):
        if ".mdb" not in path.lower() or ".gdb" not in path.lower():
            arcpy.env.workspace = path
            logger.log(10, '0 - Searching for personal geodatabases (*.MDB) in "'+input_folder+'"')
            for database in arcpy.ListWorkspaces("*", "Access"):
                arcpy.env.workspace = database
                # write main logger categories
                logger.log(10, '0 - Found personal geodatabase ('+database.split("\\")[-1]+') in "'+input_folder+'"')
                logger.log(20, '0 - Model Prepare ('+database+')')

                if arcpy.Exists(database+'\\ModelRegister'):
                    cur = arcpy.SearchCursor(database+'\\ModelRegister')
                    for row in cur:
                        modelName = row.getValue('Model')
                        typeNetwork = row.getValue('Mode').lower()
                    logger.log(10, '0 - Model is registered. Model name: '+modelName+', mode: '+typeNetwork)
                else:
                    logger.log(30, '0 - Model is not registered. Please register...')
                    raise ValueError('0 - Please register Model')

                logger.log(10, '0 - Raster processing '+input_raster+' with model '+junctions)
                # for fc in arcpy.ListFeatureClasses():
                #     if 'B_' in fc and 'msm_Link' in fc and typeNetwork == 'cs':
                #         logger.log(10, '0 - Found previous buffer '+fc+' in "'+database+', mode '+typeNetwork)
                #         buffer_found = True
                #         buffer_name = fc
                #     elif 'B_' in fc and 'mw_Pipe' in fc and typeNetwork == 'wd':
                #         logger.log(10, '0 - Found previous buffer '+fc+' in "'+database+', mode '+typeNetwork)
                #         buffer_found = True
                #         buffer_name = fc
                # if not buffer_found:
                #     logger.log(30, '0 - Please run ModelPrepare to create buffer ...')
                #     raise ValueError('0 - Please run ModelPrepare to create buffer ...')
                
                # start finding FC by matching name from definition table (Comparision.mdb)
                # rasterMask = arcpy.sa.ExtractByMask(in_raster='http://ags.cuzk.cz/arcgis/services/dmr4g/ImageServer', in_mask_data=database+'\\'+buffer_name)
                # rasterMask.save(input_folder+'\\'+buffer_name)

                arcpy.env.workspace = output_folder
                arcpy.gp.ExtractValuesToPoints_sa(junctions, input_raster, junctions+"_raster", "NONE", "VALUE_ONLY")

                logger.log(10, '0 - Raster values extracted to '+junctions+'_raster ')

except arcpy.ExecuteError:
    logger.log(40, str(arcpy.GetMessages(2)))
    #logger.error(command.CommandText) or str(sys.exc_info()[2])

except Exception as ex:
    logger.log(40, ex.args[0]+' '+str(sys.exc_info()[2]))
    #raw_input("Press enter to continue")
    #os.system("pause")