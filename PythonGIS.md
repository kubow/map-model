[15 Python Libraries for GIS and Mapping - GIS Geography](https://gisgeography.com/python-libraries-gis-mapping/)
[Essential Python Geospatial Libraries](https://carsonfarmer.com/2013/07/essential-python-geo-libraries/)

[GeospatialPython/Learn: Code and data samples from GeospatialPython.com and Books](https://github.com/GeospatialPython/Learn)

## Python GIS scripts:

[convert - Converting shapefiles to text (ASCII) files? - GIS Stack Exchange](https://gis.stackexchange.com/questions/7339/converting-shapefiles-to-text-ascii-files)
[Using PyShp to create polygon shapefiles? - GIS Stack Exchange](https://gis.stackexchange.com/questions/119160/using-pyshp-to-create-polygon-shapefiles)

## Lessons

[Lessons | GEOG 485: GIS Programming and Software Development](https://www.e-education.psu.edu/geog485/node/169)

[Geoprocessing with Python using Open Source GIS](https://www.gis.usu.edu/~chrisg/python/2009/)



  
Geospatial python [http://geospatialpython.com/](http://geospatialpython.com/)  

## pyshp

[GeospatialPython/pyshp: This library reads and writes ESRI Shapefiles in pure Python.](https://github.com/GeospatialPython/pyshp)

```python
import shapefile as shp

shapes = shp.Reader("shapefiles/blockgroups").shapes()
points = shapes[0].points
```