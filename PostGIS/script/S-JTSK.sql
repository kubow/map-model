-- Compatibility CRS for legacy ESRI/GeoServer/DHI workflows.
-- For new PostGIS data, prefer EPSG:5514: S-JTSK / Krovak East North.
-- PROJ reports ESRI:102067 as deprecated with EPSG:5514 as the replacement.
--
-- PostGIS spatial_ref_sys columns are:
--   srid, auth_name, auth_srid, srtext, proj4text
-- Do not use the SpatiaLite variant with ref_sys_name here.

DELETE FROM spatial_ref_sys
WHERE srid = 102067;

INSERT INTO spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text)
VALUES (
    102067,
    'ESRI',
    102067,
    'PROJCS["S-JTSK_Krovak_East_North",GEOGCS["GCS_S_JTSK",DATUM["D_S_JTSK",SPHEROID["Bessel_1841",6377397.155,299.1528128]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]],PROJECTION["Krovak"],PARAMETER["False_Easting",0.0],PARAMETER["False_Northing",0.0],PARAMETER["Pseudo_Standard_Parallel_1",78.5],PARAMETER["Scale_Factor",0.9999],PARAMETER["Azimuth",30.28813975277778],PARAMETER["Longitude_Of_Center",24.83333333333333],PARAMETER["Latitude_Of_Center",49.5],PARAMETER["X_Scale",-1.0],PARAMETER["Y_Scale",1.0],PARAMETER["XY_Plane_Rotation",90.0],UNIT["Meter",1.0]]',
    '+proj=krovak +lat_0=49.5 +lon_0=24.8333333333333 +alpha=30.2881397527778 +k=0.9999 +x_0=0 +y_0=0 +ellps=bessel +towgs84=589,76,480,0,0,0,0 +units=m +no_defs +type=crs'
);
