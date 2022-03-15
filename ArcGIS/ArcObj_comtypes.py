import arcpy
from ESRICOMHelpers import GetESRIModule, CType, NewObj

def GetGDBReleaseVersion(gdbPath):
    """Gets the release version of the given geodatabase."""
    esriGeoDatabase = GetESRIModule("esriGeoDatabase")
    esriGeoprocessing = GetESRIModule("esriGeoprocessing")
    gpUtilities = NewObj(esriGeoprocessing.GPUtilities, esriGeoprocessing.IGPUtilities)
    try:
        dataset = gpUtilities.OpenDatasetFromLocation(gdbPath)
        workspace = CType(dataset, esriGeoDatabase.IWorkspace)
        gdbRelease = CType(workspace, esriGeoDatabase.IGeodatabaseRelease2)
        return "%d.%d" % (gdbRelease.MajorVersion + 7, gdbRelease.MinorVersion)
    except:
        return None

if __name__ == "__main__":
    print GetGDBReleaseVersion(r"C:\GISData\test.gdb")