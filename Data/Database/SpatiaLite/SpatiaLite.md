Geocoded SQLite - SpatiaLite  
  
[Getting started with SpatiaLite](http://www.bostongis.com/?content_name=spatialite_tut01)  
  
[SQLite GeoSpatial Data](https://www.fulcrumapp.com/blog/working-with-geodata/#tools-for-working-with-sqlite)  
  
[SpatiaLite vs Shapefile](https://gis.stackexchange.com/questions/69542/advantages-of-using-spatialite-over-shapefile)  
[GeoPackage vs SpatiaLite](https://gis.stackexchange.com/questions/228210/using-geopackage-instead-of-spatialite-and-vice-versa)  
  
[SpatiaLite for Android](https://gis.stackexchange.com/questions/3554/how-to-run-spatialite-on-android)  
  
[QGIS and SpatiaLite](http://millermountain.com/geospatialblog/2017/10/23/qgis-and-spatialite/)  

## Install

Load spatialite extension problem [https://github.com/sqlitebrowser/sqlitebrowser/issues/267](https://github.com/sqlitebrowser/sqlitebrowser/issues/267)  
Load spatialite WIN10 Workaround [https://github.com/sqlitebrowser/sqlitebrowser/wiki/SpatiaLite-on-Windows#workaround-for-windows-10-failure](https://github.com/sqlitebrowser/sqlitebrowser/wiki/SpatiaLite-on-Windows#workaround-for-windows-10-failure)


## Coordinate systems

S-JTSK Krovak

```sql
DELETE FROM spatial_ref_sys WHERE srid = 102067
INSERT INTO spatial_ref_sys (srid, auth_name, auth_srid, ref_sys_name, proj4text, srtext) VALUES (102067, 'epsg', 102067, 'S-JTSK Krovak East North', '+proj=krovak +lat_0=49.5 +lon_0=24.83333333333333 +alpha=30.2881397222222 +k=0.9999 +x_0=0 +y_0=0 +ellps=bessel +units=m +towgs84=570.83789,85.682641,462.84673,4.9984501,1.5867074,5.2611106,3.5610256', 'PROJCS["SJTSK_Krovak_East_North",GEOGCS["GCS_S_JTSK",DATUM["D_S_JTSK",SPHEROID["Bessel_1841",6377397.155,299.1528128]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]],PROJECTION["Krovak"],PARAMETER["False_Easting",0], PARAMETER["False_Northing",0],PARAMETER["Pseudo_Standard_Parallel_1",78.5],PARAMETER["Scale_Factor",0.9999],PARAMETER["Azimuth",30.2881397222222],PARAMETER["Longitude_Of_Center",24.83333333333333],PARAMETER["Latitude_Of_Center",49.5], PARAMETER["X_Scale",-1], PARAMETER["Y_Scale",1],PARAMETER["XY_Plane_Rotation",90],UNIT["Meter",1]]'); 
```

 

