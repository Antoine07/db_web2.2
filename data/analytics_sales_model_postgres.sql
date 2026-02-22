-- Chapter 12: simple analytics model (star schema)
-- Grain: one row in fact_sales = one product line in one order

CREATE SCHEMA IF NOT EXISTS analytics;

CREATE TABLE IF NOT EXISTS analytics.dim_date (
  date_key INTEGER PRIMARY KEY,
  full_date DATE NOT NULL UNIQUE,
  year INTEGER NOT NULL,
  month INTEGER NOT NULL,
  day INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS analytics.dim_customer (
  customer_id SERIAL PRIMARY KEY,
  customer_email TEXT NOT NULL UNIQUE,
  customer_name TEXT NOT NULL,
  city TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS analytics.dim_product (
  product_id SERIAL PRIMARY KEY,
  product_name TEXT NOT NULL,
  category TEXT NOT NULL,
  UNIQUE (product_name, category)
);

CREATE TABLE IF NOT EXISTS analytics.fact_sales (
  sale_id BIGSERIAL PRIMARY KEY,
  order_ref TEXT NOT NULL,
  date_key INTEGER NOT NULL REFERENCES analytics.dim_date(date_key),
  customer_id INTEGER NOT NULL REFERENCES analytics.dim_customer(customer_id),
  product_id INTEGER NOT NULL REFERENCES analytics.dim_product(product_id),
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price > 0),
  line_amount NUMERIC(12,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
  UNIQUE (order_ref, date_key, customer_id, product_id, quantity, unit_price)
);

CREATE INDEX IF NOT EXISTS idx_fact_sales_date_key ON analytics.fact_sales (date_key);
CREATE INDEX IF NOT EXISTS idx_fact_sales_customer_id ON analytics.fact_sales (customer_id);
CREATE INDEX IF NOT EXISTS idx_fact_sales_product_id ON analytics.fact_sales (product_id);

-- Optional loading pattern from cleaned CSV:
-- 1) COPY into a temporary staging table
-- 2) INSERT distinct values into dimensions
-- 3) INSERT lines into fact_sales
