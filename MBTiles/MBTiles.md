#tileset #sqlite #offline #maptiling

MBTiles is a SQLite-based archive for map tiles. It can contain raster tiles or vector tiles and is widely used for offline maps, tile packaging, and upload-to-server workflows.

[MBTiles specification](https://github.com/mapbox/mbtiles-spec)

## Role

- Store a complete tile pyramid in one file.
- Package raster tiles, vector tiles, or UTFGrid-style metadata depending on the workflow.
- Move generated tiles between tools, servers, and offline clients.

## Fits with

- [Data/Tiles](../Data/Tiles/README.md) - general map tiling logic.
- [MapTiler](../MapTiler/MapTiler.md) - can generate MBTiles outputs.
- [Tippecanoe](../Tippecanoe/Tippecanoe.md) - commonly generates vector MBTiles.
- TileServer GL, Martin, MapTiler Server, and other tile servers.

## Notes

- MBTiles is a package format, not a rendering engine.
- It is convenient for local files and server uploads.
- For direct static hosting over HTTP, [PMTiles](../PMTiles/PMTiles.md) may be simpler because it is designed around range requests from a single hosted object.
