#tileset #cloud-native #static-hosting #maptiling

PMTiles is a single-file tile archive designed for efficient HTTP range requests. It can be used for vector or raster tiles without running a traditional tile server.

[protomaps/PMTiles](https://github.com/protomaps/PMTiles)

## Role

- Store a tile pyramid in one cloud-friendly file.
- Serve tiles from static object storage or a CDN.
- Avoid a tile server for many static map layers.

## Fits with

- [Data/Tiles](../Data/Tiles/README.md) - general map tiling logic.
- [Tippecanoe](../Tippecanoe/Tippecanoe.md) - generates MBTiles that can be converted to PMTiles.
- [MapLibre](../MapLibre/MapLibre.md) and Protomaps tooling.

## Compared to MBTiles

- [MBTiles](../MBTiles/MBTiles.md) is a SQLite archive, useful locally or behind a server.
- PMTiles is optimized for direct web delivery from a single hosted file.

## Links

- [PMTiles concepts](https://docs.protomaps.com/pmtiles/)
