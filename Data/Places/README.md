# Places

This section is for curated point collections: cities, landmarks, mysterious places, book references, travel targets, and other named locations.

## Current legacy examples

- [places shapefile](../Flat/Shapefile/Shapefile.md) - tracked WGS84 PointZ sample with 134 records.
- [Places.sqlite](../Database/SpatiaLite/Places.sqlite) - old SpatiaLite file. Treat it as a legacy spatial database sample, not the canonical place registry. It also contains ArcCR/admin layers.

## Recommended storage convention

Use a GeoPackage as the canonical GIS-friendly store:

- `Data/Places/places.gpkg`
- layer: `places`
- CRS: `EPSG:4326`
- geometry: `Point` or `PointZ`

Current canonical file: [places.gpkg](places.gpkg)

- `places`: 209 point features.
- `mystic`: 8 candidate point pointers from [Mystic CZ](Mystic_CZ.md). These are kept as a separate layer until promoted into canonical `places`.
- `collections`: collection registry, including `aztec`, `interesting_places`, `srazkomery`, `mystic_cz`, source lists, and catalogs.
- `sources`: present source links from the current notes.
- `place_mentions`: evidence rows linking imported place features back to their sources.

Current imported point collections:

- `aztec`: 100 Aztec treasure house waypoints, cross-checked against `Data/Flat/Aztec.gpx`.
- `interesting_places`: 34 legacy points from the shapefile.
- `srazkomery`: 75 rain gauge stations from `Data/Database/srazkomery.mdb` table `srazkomery_WGS`.
- `mystic`: 8 candidate pointers for selected mystery-place items and source pages from `Data/Places/Mystic_CZ.md`.

Keep optional exports next to it only when needed:

- `places.geojson` for easy web/debug viewing.
- `places.csv` when coordinates are enough and plain diffing matters.
- `places.parquet` or `places.geoparquet` for larger analytical workflows.
- `places.shp` only as a compatibility export.

The logical table model is sketched in [schema.sql](schema.sql).

## Minimal place fields

| Field | Purpose |
| --- | --- |
| `place_id` | Stable id, e.g. `aztec:albi` or UUID. |
| `name` | Main display name. |
| `name_ascii` | Optional ASCII/search variant. |
| `category` | Broad type, e.g. `city`, `landmark`, `mystic`, `book_reference`, `visit`. |
| `collection` | The thematic group, e.g. `aztec`, `mystic_cz`, `travel`. |
| `country` | ISO country code or country name. |
| `admin1` | Region/state when useful. |
| `locality` | City/town/nearest settlement. |
| `source_id` | Link to the source record. |
| `source_url` | Direct web/source URL when there is only one source. |
| `source_note` | Page, quote, memo, or short provenance note. |
| `confidence` | `high`, `medium`, `low`, or numeric score. |
| `status` | `candidate`, `verified`, `archived`. |

## For multiple mentions of the same place

Do not duplicate the same physical place just because it appears in several sources. Use:

- `places` - one row per real-world location.
- `sources` - one row per book, website, dataset, API, or person.
- `place_mentions` - one row per mention, with `place_id`, `source_id`, page/URL, text snippet, and confidence.
- `collections` - optional table for groups such as `aztec`, `mystic_cz`, or `fieldwork_2024`.

This keeps the map clean while preserving evidence and provenance.

## Source lists

- [Mystic CZ](Mystic_CZ.md)
