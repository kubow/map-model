## Table to spatial features merger
## Creates a spatial record for each row in a table by joining table to a feature class
## David Aalbers, Waitakere City Council GIS team, New Zealand
## david.aalbers@gmail.com
## Dec '09
##
## Updated Sept '10 
## - Performance increase by using of GP search cursors only once, Python lists do rest of work and are quicker about it
## - Percentage complete message
##





## FUNCTIONS
# Display messages
def mes(strMes, st="m"):
    print strMes
    if st == "m":
        gp.addmessage(strMes)
    elif st == "w":
        gp.addwarning(strMes)
    elif st == "e":
        gp.adderror(strMes)

    
# Create FC fields
def addfields(fc, name, type, op1="", op2="", strlength=""):
    mes("Adding field " + name + ", type " + type)
    if type == "STRING":        
        gp.addfield_management(fc, name, "TEXT", "", "", strlength) #text needs a length parameter  
    elif type in ["INTEGER", "SMALLINTEGER"]:      
        gp.addfield_management(fc, name, "LONG")
    elif type in ["SINGLE", "DOUBLE"]:
        gp.addfield_management(fc, name, "DOUBLE")   
    elif type == "DATE":
        gp.addfield_management(fc, name, "DATE")


# Report percentage processed
def reportPerc(intCur, intTot):
    global p1, p2, p3, p4, p5
    # Get percentage processed
    intPerc = round((float(intCur)/float(intTot))*100, 0)
    # Give message for %
    if p1 == 0:
        if intPerc >= 2:
            mes("2% complete...")
            p1 = 1
    elif p2 == 0:
        if intPerc >= 10:
            mes("10% complete...")
            p2 = 1
    elif p3 == 0:
        if intPerc >= 25:
            mes("25% complete...")
            p3 = 1
    elif p4 == 0:
        if intPerc >= 50:
            mes("50% complete...")
            p4 = 1
    elif p5 == 0:
        if intPerc >= 75:
            mes("75% complete...")
            p5 = 1
   





## START
# Import and Create GP
import arcgisscripting, os, sys, string
gp = arcgisscripting.create (9.3)
gp.overwriteoutput = 1


# Set params
strTable = string.replace(gp.getparameterastext(0),"\\", "/")
strTableField = gp.getparameterastext(1)
strFC = string.replace(gp.getparameterastext(2),"\\", "/")
strFCField = gp.getparameterastext(3)
strOutWS = string.upper(string.replace(gp.getparameterastext(4),"\\", "/"))
strOutFCName = (gp.getparameterastext(5))


# Or to test
##strTable = "H:\\TEMP\\TEMP.gdb\\fmerge_tab"
##strTableField = "Join_Int"
##strFC = "H:\\TEMP\\TEMP.gdb\\fmerge_fc"
##strFCField = "Property_Key"
##strOutWS = "H:\\TEMP\\TEMP.GDB"
##strOutFCName = "fmerge_result"


# Check and set output fc
if not strOutWS[-4:] == ".GDB":
    if not string.upper(strOutFCName[:-4]) == ".SHP":
        # If shapefile needs to have .shp
        strOutFCName = strOutFCName + ".shp"     
strOutFC = strOutWS + "/" + strOutFCName    
# Check if output fc exists
while gp.exists(strOutFC):    
    # Rename if exists
    if not strOutWS[-4:] == ".GDB":
        strOutFCName = strOutFCName[:-4] + "_1.shp"
    else:
        strOutFCName = strOutFCName + "_1"
    strOutFC = strOutWS + "/" + strOutFCName
    mes("Output already exists, renaming output " + strOutFCName, "w")

    
# Check the join field types and warn if not the same
descFC = gp.describe(strFC)
descTab = gp.describe(strTable)
for a in descFC.Fields:
    if a.name == strFCField:
        for b in descTab.Fields:
            if b.name == strTableField:
                mes(strTableField + " is type " + b.Type)
                mes(strFCField + " is type " + a.Type)
                if not a.Type == b.Type:
                    mes("Join fields are not the same type which could cause unexpected results", "w")

   
# Count features and add message
toprocesscnt = 0
toreadcnt = 0
# Count table rows
SCTable = gp.searchcursor(strTable)
SCTableRows = SCTable.next()
while SCTableRows:
    toprocesscnt = toprocesscnt + 1
    SCTableRows = SCTable.next()
mes(str(toprocesscnt) + " rows in table to process")
del SCTable
# Count FC rows
SCFC = gp.searchcursor(strFC)
SCFCRows = SCFC.next()
while SCFCRows:
    toreadcnt = toreadcnt + 1
    SCFCRows = SCFC.next()
mes(str(toreadcnt) + " rows in feature class to search")
del SCFC
# Percentage counters
p1 = 0
p2 = 0
p3 = 0
p4 = 0
p5 = 0






## CREATE OUTPUT
# Create the output FC
sr = descFC.spatialreference
mes("Creating feature class " + strOutFCName)
mes("In " + strOutWS)
gp.createfeatureclass_management( strOutWS, strOutFCName,  string.upper(descFC.shapetype), "", "DISABLED", "DISABLED", sr)


#Add fields to output FC
# only take compatible types 
compatfieldtypes = ["STRING", "INTEGER", "SMALLINTEGER", "SINGLE", "DOUBLE", "DATE"]
# do not copy these fields, they are already in a new fc
invalidfieldnames = ["OBJECTID", "OBJECTID_1", "SHAPE_AREA", "SHAPE_LENGTH", "SHAPE.AREA", "SHAPE.LEN"]
# add fields from table to output fc
fields1 = []
tablefieldlist = gp.listfields(strTable)
for field in tablefieldlist:
    if string.upper(field.type) in compatfieldtypes:
        # don't need to copy certain fields
        if string.upper(field.name) not in invalidfieldnames:
            if len(field.name) < 13:
                if string.upper(field.type) == "STRING":            
                    addfields(strOutFC, field.name, string.upper(field.type), "", "", field.length)
                else:
                    addfields(strOutFC, field.name, string.upper(field.type))
                # Make a list of created fields
                fields1.append(string.upper(field.name))
# add fields from supplier fc to output fc
fields2 = []
fcfieldlist = gp.listfields(strFC)
for field in fcfieldlist:
    if string.upper(field.type) in compatfieldtypes:
        # check if duplicate field names
        if string.upper(field.name) not in fields1:
            if string.upper(field.name) not in invalidfieldnames:
                if len(field.name) < 13:
                    if string.upper(field.type) == "STRING":            
                        addfields(strOutFC, field.name, string.upper(field.type), "", "", field.length)
                    else:
                        addfields(strOutFC, field.name, string.upper(field.type))    
                    # Make a list of created fields
                    fields2.append(field.name)            

   




## PROCESS TABLE
# Lists 
lstTableRows = []
lstTableRow = []
lstRemoveRows = []
# Cursor for searching through table
SCTable = gp.searchcursor(strTable)
# while searching through table rows
SCTableRows = SCTable.next()
mes("Creating list of table values")
while SCTableRows:
    lstTableRow = []
    # Add values to native python list
    for f in fields1:
        if not SCTableRows.getvalue(f) is None:
            val = str(SCTableRows.getvalue(f))   
        else:
            val = ""    
        lstTableRow.append(val)
    lstTableRows.append(lstTableRow)
    SCTableRows = SCTable.next()
del SCTableRows
del SCTable
# Get index of join field
try:
    fields1KeyInd = fields1.index(string.upper(strTableField))
except:
    mes("Join field '" + strTableField + "' has caused an error. The field name may be too long or may contain invalid characters.", "e")






## ENGINE ROOM
# Insert cursor for out FC
ICOutFC = gp.insertCursor(strOutFC)


# Loop Supplier FC
mes("Creating search cursor for featureclass")
SCFC = gp.searchcursor(strFC)
SCFCRows = SCFC.next()
mes("Processing rows")
# For each feature in FC
while SCFCRows:
    lstRemoveRows = []
    # For each table row in list
    for tabrow in lstTableRows:
        # If a match to current FC row
        if str(tabrow[fields1KeyInd]) == str(SCFCRows.GetValue(strFCField)):
            # create new row
            newrow = ICOutFC.newrow()
            # Get shape
            newrow.shape = SCFCRows.shape.getpart(0)
            # Get values from table
            fInd = 0
            for f in fields1:
                newrow.setvalue(f, tabrow[fInd])  
                fInd = fInd + 1
            # Get values from FC
            for f in fields2:
                if not SCFCRows.getvalue(f) is None: 
                    newrow.setvalue(f, SCFCRows.getvalue(f))
            # insert row
            ICOutFC.insertrow(newrow)
            lstRemoveRows.append(tabrow)
    # Eliminate processed row from table list
    for Row in lstRemoveRows:
        lstTableRows.remove(Row)    
    # Report how far through
    cnt = toprocesscnt - len(lstTableRows)
    reportPerc(cnt, toprocesscnt)
    # Next
    SCFCRows = SCFC.next()
del SCFCRows
del SCFC
del ICOutFC


# Report
mes("Processing complete")
if len(lstTableRows) > 0:
    mes(str(len(lstTableRows)) + " table values could not be matched", "w")
    mes("Unmatched " + strTableField + ":", "w")
    for unm in lstTableRows:
        mes(unm[fields1KeyInd], "w")
else:
    mes("All table rows were matched in featureclass")
    

