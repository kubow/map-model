-- Logical schema for curated point collections.
-- For a GeoPackage, keep the same attributes and store geometry in the
-- `places` layer as Point/PointZ EPSG:4326 instead of plain lon/lat only.

CREATE TABLE collections (
    collection_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    theme TEXT,
    status TEXT DEFAULT 'active'
);

CREATE TABLE sources (
    source_id TEXT PRIMARY KEY,
    collection_id TEXT REFERENCES collections(collection_id),
    title TEXT NOT NULL,
    source_type TEXT,
    url TEXT,
    author TEXT,
    publisher TEXT,
    published_at TEXT,
    license TEXT,
    note TEXT
);

CREATE TABLE places (
    place_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    name_ascii TEXT,
    category TEXT,
    collection_id TEXT REFERENCES collections(collection_id),
    country TEXT,
    admin1 TEXT,
    locality TEXT,
    lon REAL NOT NULL,
    lat REAL NOT NULL,
    z REAL,
    confidence TEXT DEFAULT 'medium',
    status TEXT DEFAULT 'candidate',
    created_at TEXT,
    updated_at TEXT
);

CREATE TABLE place_mentions (
    mention_id TEXT PRIMARY KEY,
    place_id TEXT NOT NULL REFERENCES places(place_id),
    source_id TEXT NOT NULL REFERENCES sources(source_id),
    page_ref TEXT,
    url TEXT,
    quote_text TEXT,
    note TEXT,
    confidence TEXT,
    created_at TEXT
);

CREATE INDEX idx_places_collection ON places(collection_id);
CREATE INDEX idx_places_category ON places(category);
CREATE INDEX idx_places_lon_lat ON places(lon, lat);
CREATE INDEX idx_sources_collection ON sources(collection_id);
CREATE INDEX idx_sources_type ON sources(source_type);
CREATE INDEX idx_place_mentions_place ON place_mentions(place_id);
CREATE INDEX idx_place_mentions_source ON place_mentions(source_id);
