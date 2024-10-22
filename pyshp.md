[GeospatialPython/pyshp: This library reads and writes ESRI Shapefiles in pure Python.](https://github.com/GeospatialPython/pyshp)

[pyshp · PyPI](https://pypi.org/project/pyshp/)

[convert - Converting shapefiles to text (ASCII) files? - GIS Stack Exchange](https://gis.stackexchange.com/questions/7339/converting-shapefiles-to-text-ascii-files)
[Using PyShp to create polygon shapefiles? - GIS Stack Exchange](https://gis.stackexchange.com/questions/119160/using-pyshp-to-create-polygon-shapefiles)


```python
import shapefile as shp

shapes = shp.Reader("shapefiles/blockgroups").shapes()
points = shapes[0].points
``` 
