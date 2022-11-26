[[GeoData]]

[[GeoCoding]]

# Geographic format types

- Flat Files with geographic coordinates
- [[Geodatabase]]
- [[GeoTIFF]]
- [[GeoTopoJSON]]
- [[KML-type]]
- [[PostGIS]]
- [[Shapefile]]
- [[SpatiaLite]]

# Layer sources

Various maps [http://www.webgis.com/](http://www.webgis.com/)  
  
Srovnání mapových zdrojů ČR [http://www.zememeric.cz/11-97/zabadmu.html](http://www.zememeric.cz/11-97/zabadmu.html)  
Využití DMÚ25 [http://gis.vsb.cz/GIS_Ostrava/GIS_Ova_2001/Sbornik/Referaty/langr.htm](http://gis.vsb.cz/GIS_Ostrava/GIS_Ova_2001/Sbornik/Referaty/langr.htm)  
Metadata DMU25 [http://micka.cenia.cz/metadata/index.php?ak=detailall&language=cze&uuid=8b7aef90-ef90-1b7a-a970-c88088beb3f3](http://micka.cenia.cz/metadata/index.php?ak=detailall&language=cze&uuid=8b7aef90-ef90-1b7a-a970-c88088beb3f3)  
  
WMS Download for future offline use [https://www.zimmi.cz/posts/tag/ogc.html](https://www.zimmi.cz/posts/tag/ogc.html)

## WMS

- 
- [Cenia WMS](http://geoportal.gov.cz/ArcGIS/services/CENIA/cenia_t_podklad/MapServer/WMSServer)


# Geographic coordinate systems

[Spatial Projection Systems Information](http://spatialreference.org/)
  
[Coordinate systems in EU/CZ](http://help.maptiler.org/coordinates/europe/cz)  

[Convert affine coordinates to lat/lng](https://gis.stackexchange.com/questions/8392/how-do-i-convert-affine-coordinates-to-lat-lng)


## Krovak S-JTSK

S-JTSK is the Czech coordinate system  
  

## Geoserver

  
S-JTSK has to be added to geoserver manually (Place the file epsg_override.properties to data geoserver/data/user_projections/ ).  
Then use EPSG 102067 .  
Definition: [https://epsg.io/102067](https://epsg.io/102067)  
  
[http://spatialreference.org/ref/sr-org/czech-s-jtsk-gis-esri102067/geoserver/](http://spatialreference.org/ref/sr-org/czech-s-jtsk-gis-esri102067/geoserver/)  
  


  
