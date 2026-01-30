-- Évolution JSON du fil rouge "shop" (PostgreSQL)
-- Exécution :
--   psql -h 127.0.0.1 -p 5433 -U postgres -d shop -v ON_ERROR_STOP=1 -f data/shop_json_evolution_postgres.sql

ALTER TABLE products
  ADD COLUMN IF NOT EXISTS attributes JSONB NULL;

UPDATE products
SET attributes = jsonb_build_object(
  'color', 'black',
  'size', 'M',
  'material', 'cotton',
  'tags', jsonb_build_array('basic', 'cotton')
)
WHERE id = 1;

UPDATE products
SET attributes = jsonb_build_object(
  'waist', 32,
  'length', 32,
  'fit', 'slim',
  'material', 'denim'
)
WHERE id = 3;

UPDATE products
SET attributes = jsonb_build_object(
  'size_eu', 42,
  'color', 'white',
  'material', 'leather',
  'waterproof', to_jsonb(false)
)
WHERE id = 6;

