- [[GeoData]]
- [[GeoCoding]]

# Geographic format types

[GIS file formats - Wikipedia](https://en.wikipedia.org/wiki/GIS_file_formats)

- Raster
	- [[GeoTIFF]]
	- [Raster file formats for JS mapping](https://geoexamples.com/d3/2017/11/04/raster-file-formats.html)
- Geometry
	- Flat Files with geographic coordinates
	- [[Geodatabase]]
	- [[GeoTopoJSON]]
	- [[KML-type]]
	- [[Shapefile]]
	- [[SpatiaLite]]
- [[PostGIS]] (universal holder)

# Layer sources

Various maps [http://www.webgis.com/](http://www.webgis.com/)  

Srovnání mapových zdrojů ČR [http://www.zememeric.cz/11-97/zabadmu.html](http://www.zememeric.cz/11-97/zabadmu.html)  
[Research - Department of Geoinformatics FMG VSB-TUO](https://www.hgf.vsb.cz/548/en/research/)

[GIS Ostrava - Katedra geoinformatiky HGF VŠB-TUO](https://www.hgf.vsb.cz/548/cs/o-katedre/udalosti/gis-ostrava)
- [GIS Ostrava 2001 - sborník konference](http://gisak.vsb.cz/GIS_Ostrava/GIS_Ova_2001/Sbornik/Referaty/langr.htm)

[qgis - What is the best way to manage geodata with open source software? - Geographic Information Systems Stack Exchange](https://gis.stackexchange.com/questions/97378/what-is-the-best-way-to-manage-geodata-with-open-source-software)

[GeoData Public drive](https://mygeodata.cloud/drive/public#)

[Micka Metadatový katalog](https://micka.cenia.cz/)  
[Geonorge metadata katalog](http://www.geonorge.no/geonetwork/srv/no/main.home)


## WMS

- 
- [Cenia WMS](http://geoportal.gov.cz/ArcGIS/services/CENIA/cenia_t_podklad/MapServer/WMSServer)

WMS Download for future offline use [https://www.zimmi.cz/posts/tag/ogc.html](https://www.zimmi.cz/posts/tag/ogc.html)


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
  


  
