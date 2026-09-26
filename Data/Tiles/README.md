#tileset #maptiling #web-map #data-delivery

Map tiles are a delivery strategy: geodata is split into a zoom pyramid so a map client can request only the pieces needed for the current viewport.

## Tile logic

```text
source data
  -> normalize CRS / schema / style
  -> split by zoom, x, y
  -> store as files, archive, or service
  -> render in a map client
```

Use tiles when data is too large or too frequently reused to ship as one full dataset to every client.

## Tile types

- Raster tiles - pre-rendered image tiles such as PNG, JPEG, or WebP. Good for imagery, scanned maps, hillshades, and maps whose cartography should be fixed.
- Vector tiles - encoded feature tiles, commonly Mapbox Vector Tile / MVT. Good for interactive styling, labels, filtering, and lower bandwidth for vector data.
- Terrain or elevation tiles - specialized raster/mesh encodings for relief, 3D terrain, or elevation queries.

## Addressing and metadata

- XYZ - common `z/x/y` tile addressing used by many web clients.
- TMS - similar addressing with a flipped Y axis in older workflows.
- WMTS - OGC tile service standard.
- TileJSON - metadata document describing tile URLs, bounds, zoom ranges, attribution, and vector layer metadata.

## Storage containers

- Tile folder - simple static directory tree such as `z/x/y.pbf` or `z/x/y.png`.
- [MBTiles](../../MBTiles/MBTiles.md) - SQLite archive for raster or vector tiles.
- [PMTiles](../../PMTiles/PMTiles.md) - single-file, HTTP range request friendly tile archive.
- [GeoPackage](../Database/GeoPackage/GeoPackage.md) - OGC container that can store tiled pyramids and feature tables.

## Generators

- [MapTiler](../../MapTiler/MapTiler.md) - commercial tiling, packaging, hosting, and serving ecosystem.
- [Tippecanoe](../../Tippecanoe/Tippecanoe.md) - vector tile generation from vector datasets.
- Planetiler - fast vector tile generation, especially for OpenStreetMap-scale data.
- GDAL tools such as `gdal2tiles.py` - raster tile generation.

## Servers and delivery

- [pg_tileserv](../../PostGIS/pg_tileserv.md) - dynamic vector tiles from PostGIS.
- [TiTiler](../../TiTiler/TiTiler.md) - dynamic raster tiles from COG/STAC assets.
- MapTiler Server - self-hosted tiles and map services.
- TileServer GL or Martin - common open-source tile serving options.
- Static hosting or CDN - especially useful with PMTiles or tile folders.

## Clients

- [MapLibre](../../MapLibre/MapLibre.md)
- [Leaflet](../../Leaflet/Leaflet.js.md)
- [OpenLayers](../../OpenLayers/Openlayers.md)
- [deck.gl](../../deck.gl/deck.gl.md)

## For this repository

- Keep canonical feature data in [GeoPackage](../Database/GeoPackage/GeoPackage.md) or [PostGIS](../../PostGIS/PostGIS.md).
- Tile only when the collection becomes too large, needs public web delivery, or needs repeated viewport-based access.
- For small point layers such as [Places](../Places/README.md), direct GeoPackage/GeoJSON export is usually simpler until the map grows.
