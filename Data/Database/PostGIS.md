#data-type #database #postgis #postgresql #vector #raster

PostGIS is not a single file format like GeoPackage or Shapefile. It is a PostgreSQL extension that adds spatial data types, indexes, functions, and metadata tables to a normal PostgreSQL database.

[PostGIS](../../PostGIS/PostGIS.md)

## What It Stores

- Vector geometry in `geometry` columns: points, lines, polygons, multiparts, collections, curves, TINs, polyhedral surfaces, and Z/M dimensions.
- Geographic coordinates in `geography` columns: lon/lat data measured on the spheroid, useful for global distance/area queries.
- Raster data in `raster` columns when raster support is enabled.
- Ordinary PostgreSQL attributes beside spatial columns: text, numbers, JSONB, timestamps, foreign keys, arrays, etc.
- CRS definitions in `spatial_ref_sys`.
- Spatial column metadata through catalog views such as `geometry_columns` and `geography_columns`.

## Storage Model

A PostGIS table is still a PostgreSQL table. Spatial data is stored in typed columns:

```sql
CREATE TABLE places (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL,
    geom geometry(Point, 4326)
);
```

The `geometry(Point, 4326)` type modifier records and enforces the expected geometry type and SRID. Older or more manual workflows may use check constraints instead.

The raw geometry value is stored in PostgreSQL's internal binary representation, not as a plain WKT string. Use explicit export formats when moving data out:

- WKB/EWKB for compact binary exchange.
- WKT/EWKT for human-readable SQL/debugging.
- GeoJSON, MVT, GML, KML, or FlatGeobuf through PostGIS/GDAL/client tools.
- Database dumps with `pg_dump` for PostgreSQL-native backup/restore.

Large geometries are subject to normal PostgreSQL row storage behavior, including TOAST storage for oversized values.

## Geometry vs Geography

`geometry` is the default choice for most projected and local work.

- Coordinates are interpreted in a planar coordinate system.
- Measurements use the units of the SRID, such as meters, feet, or degrees.
- It has the broadest function and index support.
- Use projected CRS values for precise local distance/area work.

`geography` is useful when coordinates are WGS84 lon/lat and measurements should account for the earth's curvature.

- Distances and areas are computed geodetically.
- It is convenient for global data.
- It has a smaller function surface and can be slower than well-chosen projected `geometry`.

## Indexes

PostGIS commonly uses PostgreSQL indexes for spatial search:

- `GiST` - the default workhorse for most geometry/geography indexing.
- `SP-GiST` - useful for some point-heavy or partitioned spatial workloads.
- `BRIN` - useful when rows are naturally clustered by location and the table is very large.

Typical index:

```sql
CREATE INDEX places_geom_gix
ON places
USING gist (geom);
```

Spatial indexes usually index bounding boxes. Many spatial predicates first use the index for a fast bounding-box candidate search, then recheck the exact geometry relationship.

## Raster Notes

PostGIS can store rasters in `raster` columns. Each raster has one or more bands and may be georeferenced.

Common patterns:

- In-database tiles for small or analytical raster workloads.
- Out-db rasters where pixel data remains outside the database and PostGIS stores references/metadata.
- Overview tables for lower-resolution zoom-out or faster approximate computation.

For cloud-native raster delivery, COG plus [TiTiler](../../TiTiler/TiTiler.md) or similar tooling is often simpler than storing pixels directly in PostGIS.

## Strengths

- Best fit for multi-user spatial editing, versioned workflows, permissions, and SQL analytics.
- Strong spatial indexing and relational joins.
- Excellent with QGIS, GDAL/OGR, GeoServer, MapServer, MapLibre services, [pg_featureserv](../../PostGIS/pg_featureserv.md), and [pg_tileserv](../../PostGIS/pg_tileserv.md).
- Keeps spatial and non-spatial attributes in one queryable model.
- Good canonical store when data has relationships, provenance, permissions, or repeated analytical use.

## Limitations

- Not a portable file by itself. Moving a PostGIS dataset usually means `pg_dump`, `ogr2ogr`, logical replication, or export to another format.
- Requires a running PostgreSQL server and PostGIS extension, so it is heavier than GeoPackage for small/offline datasets.
- Raw on-disk storage is PostgreSQL-internal; do not treat it as an interchange format.
- Very large geometries can be slow to index, transfer, and render. Subdivide, simplify, tile, or pre-aggregate when needed.
- Geometry validity is not automatic. Invalid polygons can be stored unless constraints or validation are added.
- SRID metadata does not transform coordinates by itself. Use `ST_Transform`, not just `ST_SetSRID`, when changing CRS.
- Spatial indexes help candidate search, but exact predicates can still be expensive on complex geometries.
- Raster-in-database workflows can become heavy compared with COG/STAC/cloud-raster patterns.

## Good Repository Convention

- Use [GeoPackage](GeoPackage/GeoPackage.md) for canonical small/offline datasets and portable snapshots.
- Use PostGIS when the dataset needs SQL, joins, editing, services, permissions, or repeated analysis.
- Export web delivery layers to [Data/Tiles](../Tiles/README.md), MVT, PMTiles, or GeoJSON instead of exposing huge raw tables directly.
- Keep CRS notes explicit, especially for local systems such as S-JTSK. See [S-JTSK.sql](../../PostGIS/script/S-JTSK.sql).

## Links

- [PostGIS Data Management](https://www.postgis.net/docs/using_postgis_dbmanagement.html)
- [PostGIS geometry type](https://postgis.net/docs/en/geometry.html)
- [PostGIS raster type](https://postgis.net/docs/raster.html)
- [PostGIS Raster Data Management](https://postgis.net/docs/using_raster_dataman.html)
