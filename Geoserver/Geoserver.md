#server 

[GeoServer.org](http://geoserver.org/)  
[GeoServer blog](http://blog.geoserver.org/)  

[Geoserver User Manual](http://docs.geoserver.org/stable/en/user/index.html)  

## Architecture

- Stores - main holders for data (PostGIS, Shapefile locations …)  
- Layers - Connect feature classes from workspaces  
- Styles - set up SLD styles  

## Installation

- JAVA (JRE+JDK 7/8)
- Apache - submit JRE installation directory
	- Stop Apache  
	- [Copy geoserver.war to directory](http://docs.geoserver.org/stable/en/user/installation/war.html)  
- MS Windows deploy  
	- MS Web Platform Installer 5  
	- MS Web Deploy 3.5 
- Linux way deploy  
	- [Debian installation](http://docs.geoserver.org/stable/en/user/installation/linux/debian.html)

Run with support of Apache Tomcat (7) and Samba (windows restart service apache - problem)  


## Maintain

[http://docs.geoserver.org/stable/en/user/gettingstarted/index.html](http://docs.geoserver.org/stable/en/user/gettingstarted/index.html)  
  
[Geoserver PostGIS qckstart](http://docs.geoserver.org/stable/en/user/gettingstarted/postgis-quickstart/index.html)  
  
[http://freegis.fsv.cvut.cz/gwiki/GeoServer](http://freegis.fsv.cvut.cz/gwiki/GeoServer)  
  
[GeoServer on WebServer](https://gis.stackexchange.com/questions/45222/is-it-possible-to-install-geoserver-on-a-web-server)  
  
[Creating basic WebMap](http://suite.opengeo.org/4.1/webmaps/easypublish/load.html)  

  
Serving and styling WMS with Geoserver [https://www.e-education.psu.edu/geog585/node/701](https://www.e-education.psu.edu/geog585/node/701)  
  
Styling with JSON data [http://stackoverflow.com/questions/7251163/sql-style-join-on-json-data](http://stackoverflow.com/questions/7251163/sql-style-join-on-json-data)  
  
Batch Import  
[http://permalink.gmane.org/gmane.comp.gis.geoserver.user/10824](http://permalink.gmane.org/gmane.comp.gis.geoserver.user/10824)  
[http://osgeo-org.1560.x6.nabble.com/file/n3808835/shp2geoserver.py](http://osgeo-org.1560.x6.nabble.com/file/n3808835/shp2geoserver.py)  

Bulk Importing [http://qgissextante.blogspot.cz/2013/02/bulk-importing-into-geoserver.html](http://qgissextante.blogspot.cz/2013/02/bulk-importing-into-geoserver.html)

[GeoServer SpatiaLite Extension](http://suite.opengeo.org/docs/latest/geoserver/community/spatialite/index.html)  
  
[GeoServer REST client](http://docs.geoserver.org/latest/en/user/extensions/importer/rest_examples.html)  
  
### REST API 

[Adding layers usin REST API](http://boundlessgeo.com/2012/10/adding-layers-to-geoserver-using-the-rest-api/)  
[http://geoserver.geo-solutions.it/multidim/en/rest/index.html](http://geoserver.geo-solutions.it/multidim/en/rest/index.html)  
  
  
Animation

[http://gis.stackexchange.com/questions/67206/radar-data-animated-gif-in-geoserver](http://gis.stackexchange.com/questions/67206/radar-data-animated-gif-in-geoserver)  
WMS Animator [https://github.com/geoserver/geoserver/wiki/GSIP-62---WMS-animator](https://github.com/geoserver/geoserver/wiki/GSIP-62---WMS-animator)
Geoserver animreflector [http://docs.geoserver.org/2.2.1/user/tutorials/animreflector.html](http://docs.geoserver.org/2.2.1/user/tutorials/animreflector.html)  
[http://stackoverflow.com/questions/32397744/geoserver-time-slider-for-imagemosaic-plugin-for-raster-time-series-data](http://stackoverflow.com/questions/32397744/geoserver-time-slider-for-imagemosaic-plugin-for-raster-time-series-data)


### Styling

Join WFS layer to a table [http://gis.stackexchange.com/questions/19454/how-to-join-a-wfs-layer-to-a-stand-alone-table-in-openlayers](http://gis.stackexchange.com/questions/19454/how-to-join-a-wfs-layer-to-a-stand-alone-table-in-openlayers)  
  
Styling - Symbology (SLD)  
[http://docs.geoserver.org/latest/en/user/styling/sld-working.html](http://docs.geoserver.org/latest/en/user/styling/sld-working.html)  
[http://docs.geoserver.org/latest/en/user/styling/sld-reference/index.html](http://docs.geoserver.org/latest/en/user/styling/sld-reference/index.html)  
[http://docs.geoserver.org/latest/en/user/styling/sld-cookbook/index.html](http://docs.geoserver.org/latest/en/user/styling/sld-cookbook/index.html)  
[http://docs.geoserver.org/stable/en/user/styling/sld-cookbook/lines.html](http://docs.geoserver.org/stable/en/user/styling/sld-cookbook/lines.html)  
[http://suite.opengeo.org/docs/latest/geoserver/styling/sld-extensions/index.html](http://suite.opengeo.org/docs/latest/geoserver/styling/sld-extensions/index.html)