-- Chapter 12: load cleaned CSV into analytics model
-- Run after data/analytics_sales_model_postgres.sql

CREATE TABLE IF NOT EXISTS analytics.stg_sales_clean (
  order_ref TEXT,
  order_date DATE,
  customer_email TEXT,
  customer_name TEXT,
  city TEXT,
  product_name TEXT,
  category TEXT,
  quantity INTEGER,
  unit_price NUMERIC(10,2),
  line_amount NUMERIC(12,2)
);

TRUNCATE TABLE analytics.stg_sales_clean;

-- psql client-side import:
-- psql -h 127.0.0.1 -p 5433 -U postgres -d shop -f data/analytics_sales_load_postgres.sql
\copy analytics.stg_sales_clean (order_ref, order_date, customer_email, customer_name, city, product_name, category, quantity, unit_price, line_amount) FROM 'data/sales_clean_etl_demo.csv' WITH (FORMAT csv, HEADER true);

INSERT INTO analytics.dim_date (date_key, full_date, year, month, day)
SELECT DISTINCT
  TO_CHAR(order_date, 'YYYYMMDD')::INTEGER AS date_key,
  order_date AS full_date,
  EXTRACT(YEAR FROM order_date)::INTEGER AS year,
  EXTRACT(MONTH FROM order_date)::INTEGER AS month,
  EXTRACT(DAY FROM order_date)::INTEGER AS day
FROM analytics.stg_sales_clean
ON CONFLICT (date_key) DO NOTHING;

INSERT INTO analytics.dim_customer (customer_email, customer_name, city)
SELECT DISTINCT customer_email, customer_name, city
FROM analytics.stg_sales_clean
ON CONFLICT (customer_email) DO NOTHING;

INSERT INTO analytics.dim_product (product_name, category)
SELECT DISTINCT product_name, category
FROM analytics.stg_sales_clean
ON CONFLICT (product_name, category) DO NOTHING;

INSERT INTO analytics.fact_sales (order_ref, date_key, customer_id, product_id, quantity, unit_price)
SELECT
  s.order_ref,
  TO_CHAR(s.order_date, 'YYYYMMDD')::INTEGER AS date_key,
  c.customer_id,
  p.product_id,
  s.quantity,
  s.unit_price
FROM analytics.stg_sales_clean s
JOIN analytics.dim_customer c ON c.customer_email = s.customer_email
JOIN analytics.dim_product p ON p.product_name = s.product_name AND p.category = s.category
ON CONFLICT (order_ref, date_key, customer_id, product_id, quantity, unit_price) DO NOTHING;
