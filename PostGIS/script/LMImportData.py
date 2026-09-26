dllpath = app.WorkspaceSettings.GetValue('LeakageMonitorScriptsSettings', 'LMEngineDllFullPath');

import clr
clr.AddReferenceToFileAndPath(dllpath)
# clr.AddReferenceToFileAndPath(r'c:\Program Files (x86)\DHI\MIKE CUSTOMISED\Platform\DHI.Solutions.LeakageMonitor.Engine.dll')
from DHI.Solutions.LeakageMonitor.Engine import *

clr.AddReference("System")
clr.AddReference("System.Data")
from System import DateTime
from System.Data.OleDb import OleDbDataReader, OleDbConnection, OleDbCommand

# runtime.config contains connection to deployed file DHI.Solutions.CZ.Sql.dll
clr.AddReference('DHI.Solutions.CZ.Sql')
from DHI.Solutions.CZ.Sql import SqlExecuter

import datetime
import calendar
from datetime import date, timedelta
import time
import logging
import os, sys
import csv

def LM_ImportData():
    """
    <Script>
    <Author>DHI</Author>
    <Description>Running of LM Importing of data</Description>
    </Script>
    """
    # write your code here
    lme = LeakageMonitorEngine()
    lme.updateDbFromScadaDbMC()
    pass;

def RunZISImport():
    """
    <Script>
    <Author>jav</Author>
    <Description>Import ZIS Data for NRW</Description>
    </Script>
    """
    # prepare initials
    lme=LeakageMonitorEngine()
    executer_sql=SqlExecuter()
    #logging.basicConfig(filename='C:\\_Model\\logfile_ZIS.txt',level=logging.DEBUG,format='%(asctime)s %(message)s',datefmt='%m/%d/%Y %I:%M:%S %p')
    logFile='c:\\_Model\\logfile_ZIS.txt'
    logFileObj=open(logFile, 'r+')
    #logging.info('Spouštím import dat ZIS ...') 
    #prepare variables
    dataLocation = r'C:\DHI\LM\VST\USYS-DHI'
    runDate=datetime.date.today().strftime("20%y_%m")
    
    # load tables and data to variables
    # backup - sensorTableLM=lme.getSensorsDataTableMC()
    #sql = 'SELECT timeserieid, MAX(measureddata.time) FROM "LeakMonitorApp".measureddata WHERE timeserieid < 40 GROUP BY timeserieid ORDER BY timeserieid;'
    sql = 'SELECT id, name, sourceid FROM "LeakMonitorApp".timeseries WHERE tstypeid = 6 ORDER BY id;'
    executer_sql.Execute(sql)
    sensorTable=executer_sql.ResultTable
    folderList=[x[0] for x in os.walk(dataLocation)]
    folderDatesList=[]
    for i in range(1, len(folderList)):
        folderDate=os.path.basename(folderList[i])
        folderDatesList.append(date(int(folderDate.split('_')[0]),int(folderDate.split('_')[1]),1))
        if i < 2:
            folderDateMax=date(int(folderDate.split('_')[0]),int(folderDate.split('_')[1]),1)
        elif date(int(folderDate.split('_')[0]),int(folderDate.split('_')[1]),1) > folderDateMax:
            folderDateMax=date(int(folderDate.split('_')[0]),int(folderDate.split('_')[1]),1)
    print(str(datetime.date.today())+' / Spouštím import dat ZIS ...') 
    logFileObj.write(str(datetime.date.today())+' - Spouštím import dat ZIS ...'.encode('utf-16')+'\n')
    
    
    # start iterating sensors data
    for sensor in sensorTable.Rows:
        sql = 'SELECT timeserieid, MAX(measureddata.time) FROM "LeakMonitorApp".measureddata WHERE timeserieid = '+str(sensor.ItemArray[2])+' GROUP BY timeserieid ORDER BY timeserieid;'
        executer_sql.Execute(sql)
        tserieTable=executer_sql.ResultTable
        tserieName=sensor.ItemArray[1]
        # connect sensor with time serie data
        for tserie in tserieTable.Rows:
            tserieLastUpdate=date(tserie.ItemArray[1].Year, tserie.ItemArray[1].Month,1)
            #logging.info('TS id:'+str(tserie.ItemArray[2])+' - '+tserie.ItemArray[1])
            print('sid: '+str(tserie.ItemArray[0])+' TS id: '+str(sensor.ItemArray[0])+' - '+tserieName+' (naposledy aktualizovano pro datum '+str(tserieLastUpdate)+')')
            logFileObj.write('sid: '+str(tserie.ItemArray[0])+' TS id: '+str(sensor.ItemArray[0])+' - '+tserieName.encode('utf-8')+' (naposledy aktualizováno pro datum '.encode('utf-8')+str(tserieLastUpdate)+')\n')
            # find new data in folder
            if add_months(folderDateMax,1)==tserieLastUpdate:
                print('¨¨¨v databazi jsou k dispozici nejnovejsi data...')
                logFileObj.write('¨¨¨v databázi jsou k dispozici nejnovejší data...'.encode('utf-16')+'\n')
            elif add_months(folderDateMax,1)>tserieLastUpdate:
                for folderDate in folderDatesList:
                    if add_months(folderDate,1)>tserieLastUpdate:
                        folderPath=dataLocation+'\\'+str(folderDate.year)+'_'+str('{:02}'.format(folderDate.month))
                        print('¨¨¨nalezeny novejsi data, spoustim import ze slozky: '+folderPath)
                        logFileObj.write('¨¨¨nalezeny novější data, spouštím import ze složky: '.encode('utf-16')+folderPath+'\n')
                        sArea = folderPath+'\DHI-OBLASTI.csv'
                        sCons = folderPath+'\DHI-SPOTREBY.csv'
                        ImportValues(sensor.ItemArray[0], sArea, sCons, logFileObj)
            else:
                print('¨¨¨data z budoucnosti...')
                logFileObj.write('¨¨¨data z budoucnosti...'.encode('utf-16')+'\n')
                
    logFileObj.close()

def RunDataloggerImport():
    """
    <Script>
    <Author>jav</Author>
    <Description>Import data form Dataloggers</Description>
    </Script>
    """
    # prepare initials
    lme=LeakageMonitorEngine()
    executer_sql=SqlExecuter()
    #logging.basicConfig(filename='C:\\_Model\\logfile_ZIS.txt',level=logging.DEBUG,format='%(asctime)s %(message)s',datefmt='%m/%d/%Y %I:%M:%S %p')
    #logging.info('Spouštím import dat ZIS ...') 
    logFile='c:\\_Model\\logfile_NRW.txt'
    logFileObj=open(logFile, 'r+')
    #prepare variables
    dataLocation = r'C:\DHI\LM\VST\USYS-DHI'
    runDate=datetime.date.today().strftime("20%y_%m")
    
    # load tables and data to variables
    # backup - sensorTableLM=lme.getSensorsDataTableMC()
    #sql = 'SELECT timeserieid, MAX(measureddata.time) FROM "LeakMonitorApp".measureddata WHERE timeserieid > 182 and timeserieid < 188 GROUP BY timeserieid ORDER BY timeserieid;'
    sql = 'SELECT id, name, sourceid FROM "LeakMonitorApp".timeseries WHERE tstypeid = 5 ORDER BY id;'
    executer_sql.Execute(sql)
    sensorTable=executer_sql.ResultTable
    folderList=[x[0] for x in os.walk(dataLocation)]
    folderDatesList=[]
    for i in range(1, len(folderList)):
        folderDate=os.path.basename(folderList[i])
        folderDatesList.append(date(int(folderDate.split('_')[0]),int(folderDate.split('_')[1]),1))
        if i < 2:
            folderDateMax=date(int(folderDate.split('_')[0]),int(folderDate.split('_')[1]),1)
        elif date(int(folderDate.split('_')[0]),int(folderDate.split('_')[1]),1) > folderDateMax:
            folderDateMax=date(int(folderDate.split('_')[0]),int(folderDate.split('_')[1]),1)
    print(str(datetime.date.today())+' / Spouštím import dat Datalogerů ...') 
    logFileObj.write(str(datetime.date.today())+' / Spouštím import dat Datalogerů ...'.encode('utf-16')+'\n')
    
    # start iterating sensors data
    for sensor in sensorTable.Rows:
        sql = 'SELECT timeserieid, MAX(measureddata.time) FROM "LeakMonitorApp".measureddata WHERE timeserieid = '+str(sensor.ItemArray[2])+' GROUP BY timeserieid ORDER BY timeserieid;'
        executer_sql.Execute(sql)
        tserieTable=executer_sql.ResultTable
        tserieName=sensor.ItemArray[1]
        # connect sensor with time serie data
        for tserie in tserieTable.Rows:
            tserieLastUpdate=date(tserie.ItemArray[1].Year, tserie.ItemArray[1].Month,1)
            #logging.info('TS id:'+str(tserie.ItemArray[2])+' - '+tserie.ItemArray[1])
            print('sid: '+str(tserie.ItemArray[0])+' TS id: '+str(sensor.ItemArray[0])+' - '+tserieName+' (naposledy aktualizovano pro datum '+str(tserieLastUpdate)+')')
            logFileObj.write('sid: '+str(tserie.ItemArray[0])+' TS id: '+str(sensor.ItemArray[0])+' - '+tserieName.encode('utf-8')+' (naposledy aktualizováno pro datum '.encode('utf-16')+str(tserieLastUpdate)+')\n')
            # find new data in folder
            if add_months(folderDateMax,1)==tserieLastUpdate:
                print('¨¨¨v databazi jsou k dispozici nejnovejsi data...')
                logFileObj.write('¨¨¨v databázi jsou k dispozici nejnovejší data...'.encode('utf-16')+'\n')
            elif add_months(folderDateMax,1)>tserieLastUpdate:
                for folderDate in folderDatesList:
                    if add_months(folderDate,1)>tserieLastUpdate:
                        folderPath=dataLocation+'\\'+str(folderDate.year)+'_'+str('{:02}'.format(folderDate.month))
                        print('¨¨¨nalezeny novejsi data, spoustim import ze slozky: '+folderPath)
                        logFileObj.write('¨¨¨nalezeny novější data, spouštím import ze složky: '.encode('utf-16')+folderPath+'\n')
                        sArea = folderPath+'\DHI-OBLAST-SZTD.csv'
                        sCons = folderPath+'\DHI-SZTD.csv'
                        ImportValues(sensor.ItemArray[0], sArea, sCons, logFileObj)
            else:
                print('¨¨¨data z budoucnosti...')
                logFileObj.write('¨¨¨data z budoucnosti...'.encode('utf-16')+'\n')
                
    logFileObj.close()
    
def ImportValues(sID, csv_merne_okrsky, csv_merne_mista, logFileObj):
    final_table = CreateTable(sID, csv_merne_okrsky, csv_merne_mista)    
    items = []
        
    for a in xrange(len(final_table)):    
        timeserie_id_mo = int(final_table[a][0])
        time_mo = "'" + final_table[a][2] + "'"
        value_mo = final_table[a][1] / 86.4
        print timeserie_id_mo, time_mo, value_mo
        logFileObj.write('¨¨¨data pro vložení : (%s, %s, %s)'.encode('utf-8') % (timeserie_id_mo, time_mo, value_mo))
        item1 = 'INSERT INTO "LeakMonitorApp".measureddata (timeserieid, time, value) VALUES (%s, %s, %s)' % (timeserie_id_mo, time_mo, value_mo)
        items.append(item1)
    
    print('Number of sqls to be performed: ' + str(len(items)))

    executer = SqlExecuter()
    for item in items:
        print item
    
        res = executer.Execute(item)
        print res
        if (res != True):
            print executer.ErrorMessage
        else:
            print executer.ResultTable
            
        print '---------------------------' 

def CreateTable(sID, csv_mo, csv_mm):
    
    #    list mernych okrsku
    list_MO_all = []
    list_MM_all = []
    invoice_water_list = []
    invoice_list1 = []
    final_table = []
    
    sum_spotreba_0 = 0
    sum_spotreba_empty = 0
    sum_pocetdni_0 = 0
    sum_spotreba_all = 0
    sum_NO_MO = 0
      
    with open(csv_mo, 'rb') as csv_oblasti:
    
        in_oblasti = csv.reader(csv_oblasti, delimiter = ';')

        ##row_count1 = sum(1 for row in in_oblasti)
        #   preskoc prvni radek s header
        next(in_oblasti)

        for row in in_oblasti:

            list_MM_all.append(row[0].strip())
            list_MO_all.append(row[1].strip())
            invoice_list1.append(row[1].strip())

        list_MO_unique = list(set(invoice_list1))

        for i in xrange(len(list_MO_unique)):

            invoice_water_list.append([list_MO_unique[i], 0, 0, 0])

        with open(csv_mm, 'rb') as csv_spotreba:

            in_spotreba = csv.reader(csv_spotreba, delimiter = ';')
            ##row_count2 = sum(1 for row in in_spotreba)
            next(in_spotreba)
            mesic = row[0]
            for row in in_spotreba:

                id_merak = row[1].strip()
                ##print id_merak, len(row[7])

                if id_merak in list_MM_all:
                    ##print id_merak, len(list_MM_all)
                    sum_spotreba_all += 1
                    #   check if value = 0 or ''
                    if row[7].strip() == str(0):
                        # write into log file..
                        ##print('Merne Misto ' + str(id_merak) + ' ma spotrebu 0!')
                        sum_spotreba_0 += 1
                    elif not row[7].strip():
                        # write into log file..
                        ##print('Merne Misto ' + str(id_merak) + ' nema zadnou spotrebu! (Prazdna hodnota)')
                        sum_spotreba_empty += 1
                    else:
                        try:
                            spotreba = float(row[7].replace(',','.'))# / float(row[6])
                        except ZeroDivisionError:
                            ##print('Pocet dni = 0')
                            sum_pocetdni_0 += 1
                        MM_index = list_MM_all.index(id_merak)
                        MM_MO = list_MO_all[MM_index]
                        for j in xrange(len(invoice_water_list)):
                            ##print invoice_water_list[j][0], int(MM_MO)
                            if MM_MO == invoice_water_list[j][0]:
                                invoice_water_list[j][1] += spotreba
                                invoice_water_list[j][2] += 1
                                break
                            elif not MM_MO.strip():
                                invoice_water_list[0][1] += spotreba
                                invoice_water_list[0][2] += 1
                                break
                        ##print id_merak, sum_spotreba_all
                        ##print id_merak, mesic, row[7], row[6], spotreba, MM_index, MM_MO
                else:
                    ##print('Merak ID = ' + str(id_merak) + ' nema prirazeny merny okrsek.')
                    sum_NO_MO +=1
    
    perioda = row[0].strip()
    year = perioda[0:4]
    month = perioda[4:]
    month_extent = calendar.monthrange(int(year),int(month.strip('0')))[1]
    #(jav begin edit)
    # v pripade prosince appendujeme leden nasledujciho roku / jinak 1. nasledujiciho mesice
    if int(month)==12:
        first_day = datetime.date(int(year)+1, 1, 1).strftime('%Y/%m/%d')
        #last_day = datetime.date(int(year), int(month), int(month_extent)).strftime('%Y/%m/%d')
    else:
        first_day = datetime.date(int(year), int(month)+1, 1).strftime('%Y/%m/%d')
        #last_day = datetime.date(int(year), int(month), int(month_extent)).strftime('%Y/%m/%d')

    for h in xrange(len(invoice_water_list)):
        MO_id = invoice_water_list[h][0]
        if not MO_id.strip():
            MO_id = 'None'
            continue
        elif int(sID)==int(MO_id):
            spotreba_total = invoice_water_list[h][1]
            final_table.append([MO_id, spotreba_total, first_day])
            #final_table.append([MO_id, spotreba_total, last_day])
    
    #(jav end edit)
    return final_table
        
def add_months(sourcedate,months):
    month = sourcedate.month - 1 + months
    year = int(sourcedate.year + month / 12 )
    month = month % 12 + 1
    day = min(sourcedate.day,calendar.monthrange(year,month)[1])
    return datetime.date(year,month,day)
