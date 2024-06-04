Spatial database extender for PotgreSQL

https://postgis.net/

[PostGIS in Action](http://www.postgis.us/)
[Planet PostGIS](http://planet.postgis.net/)
[Postgis @ StackExchange](https://gis.stackexchange.com/questions/tagged/postgis)

[postgisQueryBuilder | GEOGEARS](https://geogear.wordpress.com/postgisquerybuilder-v1-6-cheatsheet/)

[Part 1: Loading OpenStreetMap data into PostGIS: An Almost Idiot's Guide](http://www.bostongis.com/?content_name=loading_osm_postgis#229)


## QGIS
[Introduction to spatial databases with PostGIS and QGIS](http://millermountain.com/geospatialblog/2018/02/21/spatial-databases-postgis-qgis/)
[Opening Data from PostgreSQL — QGIS Documentation documentation](https://docs.qgis.org/3.22/en/docs/user_manual/managing_data_source/opening_data.html#postgresql-service-connection-file)
[Visualizing PostGIS Queries in QGIS using RT Sql Layer Plugin | Free and Open Source GIS Ramblings](https://anitagraser.com/2010/10/16/visualizing-postgis-queries-in-qgis-using-rt-sql-layer-plugin/)


## Coordinate systems

Stored in PostgreSQL table spatial_ref_sys

```sql
DELETE FROM spatial_ref_sys WHERE srid = 102067
INSERT INTO spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) VALUES (102067, 'ESRI', 102067, 'PROJCS["SJTSK_Krovak_East_North",GEOGCS["GCS_S_JTSK",DATUM["D_S_JTSK",SPHEROID["Bessel_1841",6377397.155,299.1528128]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]],PROJECTION["Krovak"],PARAMETER["False_Easting",0], PARAMETER["False_Northing",0],PARAMETER["Pseudo_Standard_Parallel_1",78.5],PARAMETER["Scale_Factor",0.9999],PARAMETER["Azimuth",**30.2881397222222****],PARAMETER["Longitude_Of_Center",24.83333333333333],PARAMETER["Latitude_Of_Center",49.5], PARAMETER["X_Scale",-1], PARAMETER["Y_Scale",1],PARAMETER["XY_Plane_Rotation",90],UNIT["Meter",1]]','+proj=krovak +lat_0=49.5 +lon_0=24.83333333333333 +alpha=30.2881397222222 +k=0.9999 +x_0=0 +y_0=0 +ellps=bessel +units=m +towgs84=570.83789,85.682641,462.84673,4.9984501,1.5867074,5.2611106,3.5610256'); 
```

 