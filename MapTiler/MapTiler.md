#tileset #tool #server #cloud #maptiling

MapTiler is a production map tiling and hosting ecosystem. Treat it as a practical bridge between source geodata and web-map delivery, not as a data format by itself.

[MapTiler](https://www.maptiler.com/)

## Role

- Turn raster or vector source data into tiled map products.
- Package generated tiles as MBTiles, GeoPackage, or a tile folder.
- Host tiles through MapTiler Cloud or MapTiler Server.
- Consume tiles in web clients through TileJSON, XYZ-style URLs, MapLibre-compatible styles, or SDKs.

## Pipeline

```text
source geodata
  -> clean / reproject / style
  -> tile pyramid
  -> package or serve
  -> web map client
```

Common outputs:

- [MBTiles](../MBTiles/MBTiles.md) - SQLite tile archive, common for offline and server upload workflows.
- [GeoPackage](../Data/Database/GeoPackage/GeoPackage.md) - OGC container that can hold features and tile tables.
- Tile folders - `z/x/y` directories for simple static hosting.
- TileJSON/WMTS endpoints - web-facing metadata and tile access.

## Where it fits

- Use MapTiler Engine when a desktop or batch workflow needs to convert imagery, scanned maps, vector data, or prepared GIS data into map tiles.
- Use MapTiler Server when tiles should be self-hosted without building a custom tile service.
- Use MapTiler Cloud when hosted basemaps, tile hosting, APIs, and managed delivery are acceptable.
- Keep low-level formats and serving options documented separately: [Data/Tiles](../Data/Tiles/README.md), [PMTiles](../PMTiles/PMTiles.md), [Tippecanoe](../Tippecanoe/Tippecanoe.md), [TiTiler](../TiTiler/TiTiler.md), [pg_tileserv](../PostGIS/pg_tileserv.md).

## Comparisons

- [Tippecanoe](../Tippecanoe/Tippecanoe.md) - open-source vector tile generation from GeoJSON/CSV-style inputs.
- [pg_tileserv](../PostGIS/pg_tileserv.md) - dynamic vector tiles directly from PostGIS.
- [TiTiler](../TiTiler/TiTiler.md) - dynamic raster tiles from COG/STAC sources.
- [PMTiles](../PMTiles/PMTiles.md) - cloud-friendly single-file tile archive for static hosting.

## Links

- [MapTiler Engine output options](https://docs.maptiler.com/engine/output-options/)
- [MapTiler Engine supported formats](https://docs.maptiler.com/guides/map-tiling-hosting/data-processing/supported-formats/)
- [MapTiler Server technical specification](https://docs.maptiler.com/guides/self-hosting/map-server/maptiler-server-technical-specification/)
