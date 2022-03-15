import os, sys
import arcpy
import numpy
import string, unicodedata, time
import logging
import pyodbc

# working Directory setting
folder = os.getcwd()
input_folder = folder+'\\Inputs\\'
output_folder = folder+'\\Outputs\\'
database = output_folder+'Model.mdb'
comparisonDB = output_folder+'Comparison.mdb'

# load query to restrict selection - from ModelRegistrationTable
arcpy.env.workspace=database+'\\ModelRegister'
if arcpy.Exists(database+'\\ModelRegister'):
    cur = arcpy.SearchCursor(database+'\\ModelRegister')
    for row in cur:
        typeNetwork = row.getValue('Mode').lower()
        modelName = row.getValue('Model')
        queryArea = row.getValue('Area')
        queryBufferArea = row.getValue('BufferArea')
        bufferSize = row.getValue('BufferSize')
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

try:
    arcpy.env.workspace = database
    logger.log(10, '0 ; Model is registered. Model name: '+modelName+', mode: '+typeNetwork+', arguments'+str(argument))
    logger.log(10, '3 ; Searching Model.mdb in '+output_folder)
    logger.log(20, '3 ; Model Prepare buffer in ('+database+')')

    logger.log(10, '3 ; Searching for previous buffers in "'+database+' database')
    for fc in arcpy.ListFeatureClasses():
        if 'Buffer' in fc or 'B_' in fc or 'Buff_' in fc:
            arcpy.env.workspace = fc
            logger.log(10, '3 ; Found previous buffer '+fc+' in "'+database+' and deleting...')
            arcpy.Delete_management(fc)
            logger.log(10, '3 ; Finished clearing Buffer feature class '+fc+' in "'+database)

    arcpy.env.workspace = database
    # start finding FC by matching name from definition table (Comparision.mdb)
    for fds in arcpy.ListDatasets():
        logger.log(10, '0 ; Searching dataset "'+fds+'" for pipes feature class in "'+database)
        for fc in arcpy.ListFeatureClasses("*","All",fds):
                if 'mw_Pipe' == fc and typeNetwork == 'wd':
                    arcpy.env.workspace = fc
                    logger.log(10, '3 ; Found pipes feature class '+fc+' in '+database+'\\'+fds+' / creating Buffer '+str(bufferSize)+' m')
                    arcpy.Buffer_analysis(database+'\\'+fds+'\\'+fc,database+'\\'+"B_"+fc,str(bufferSize)+" Meters","FULL","ROUND","NONE","#")
                    logger.log(10, '3 ; Buffer '+fc+' in '+database+'\\'+fds+' created')
                if 'msm_Link' == fc and typeNetwork == 'cs':
                    arcpy.env.workspace = fc
                    logger.log(10, '3 ; Found pipes feature class '+fc+' in '+database+'\\'+fds+' / creating Buffer '+str(bufferSize)+' m')
                    arcpy.Buffer_analysis(database+'\\'+fds+'\\'+fc,database+'\\'+"B_"+fc, str(bufferSize)+" Meters","FULL","ROUND","NONE","#")
                    logger.log(10, '3 ; Buffer '+fc+' in '+database+'\\'+fds+' created')

except arcpy.ExecuteError:
    logger.log(40, str(arcpy.GetMessages(2)))
    #logger.error(command.CommandText) or str(sys.exc_info()[2])

except Exception as ex:
    logger.log(40, ex.args[0]+' '+str(sys.exc_info()[2]))
    #raw_input("Press enter to continue")
    #os.system("pause")

