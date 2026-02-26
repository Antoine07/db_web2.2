-- Fil rouge "shop" (PostgreSQL)
-- Exécution :
--   psql -h 127.0.0.1 -p 5433 -U postgres -d shop -v ON_ERROR_STOP=1 -f data/shop_seed_postgres.sql

-- Note : ce seed suppose que vous venez de recréer le schéma (IDs 1..N).
INSERT INTO categories (name) VALUES
  ('Hauts'),
  ('Pantalons'),
  ('Chaussures');

INSERT INTO products (category_id, name, sku, price, stock) VALUES
  (1, 'T-shirt basique noir', 'TOP-TS-001', 14.00, 200),
  (1, 'Sweat à capuche gris', 'TOP-HOOD-001', 49.00, 70),
  (2, 'Jean brut slim', 'PANT-JEANS-001', 69.00, 55),
  (2, 'Chino beige', 'PANT-CHINO-001', 59.00, 40),
  (2, 'Jogging noir', 'PANT-JOG-001', 39.00, 25),
  (3, 'Baskets blanches', 'SHOE-SNK-001', 89.00, 35),
  (3, 'Bottines cuir', 'SHOE-BOT-001', 129.00, 0),
  (3, 'Sandales', 'SHOE-SAND-001', 29.00, 60);

INSERT INTO customers (email, first_name, last_name, phone) VALUES
  ('sam@demo.test', 'Sam', 'Lopez', NULL),
  ('lea@demo.test', 'Léa', 'Martin', '+33 6 00 00 00 01'),
  ('nina@demo.test', 'Nina', 'Diallo', NULL),
  ('tom@demo.test', 'Tom', 'Nguyen', '+33 6 00 00 00 02'),
  ('alex@demo.test', 'Alex', 'Bernard', NULL);

INSERT INTO orders (customer_id, status, ordered_at) VALUES
  (1, 'paid',     '2025-01-02 10:15:00'),
  (1, 'shipped',  '2025-01-10 14:20:00'),
  (2, 'pending',  '2025-01-11 09:05:00'),
  (3, 'paid',     '2025-01-15 18:40:00'),
  (4, 'cancelled','2025-02-01 12:00:00'),
  (2, 'paid',     '2025-02-03 16:30:00');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (1, 1, 1, 14.00),
  (1, 4, 1, 59.00),
  (2, 3, 1, 69.00),
  (2, 6, 2, 89.00),
  (3, 2, 1, 49.00),
  (3, 7, 1, 129.00),
  (4, 5, 1, 39.00),
  (4, 4, 1, 59.00),
  (4, 8, 1, 29.00),
  (5, 6, 1, 89.00),
  (6, 1, 1, 14.00),
  (6, 2, 1, 49.00),
  (6, 6, 3, 89.00);
