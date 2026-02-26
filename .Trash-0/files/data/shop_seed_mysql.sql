-- Fil rouge "shop" (MySQL 8+)
-- Execution:
--   mysql -u root -p < data/shop_seed_mysql.sql

USE shop;

INSERT INTO categories (id, name) VALUES
  (1, 'Hauts'),
  (2, 'Pantalons'),
  (3, 'Chaussures');

INSERT INTO products (id, category_id, name, sku, price, stock) VALUES
  (1, 1, 'T-shirt basique noir', 'TOP-TS-001', 14.00, 200),
  (2, 1, 'Sweat a capuche gris', 'TOP-HOOD-001', 49.00, 70),
  (3, 2, 'Jean brut slim', 'PANT-JEANS-001', 69.00, 55),
  (4, 2, 'Chino beige', 'PANT-CHINO-001', 59.00, 40),
  (5, 2, 'Jogging noir', 'PANT-JOG-001', 39.00, 25),
  (6, 3, 'Baskets blanches', 'SHOE-SNK-001', 89.00, 35),
  (7, 3, 'Bottines cuir', 'SHOE-BOT-001', 129.00, 0),
  (8, 3, 'Sandales', 'SHOE-SAND-001', 29.00, 60);

INSERT INTO customers (id, email, first_name, last_name, phone) VALUES
  (1, 'sam@demo.test', 'Sam', 'Lopez', NULL),
  (2, 'lea@demo.test', 'Lea', 'Martin', '+33 6 00 00 00 01'),
  (3, 'nina@demo.test', 'Nina', 'Diallo', NULL),
  (4, 'tom@demo.test', 'Tom', 'Nguyen', '+33 6 00 00 00 02'),
  (5, 'alex@demo.test', 'Alex', 'Bernard', NULL);

INSERT INTO orders (id, customer_id, status, ordered_at) VALUES
  (1, 1, 'paid', '2025-01-02 10:15:00'),
  (2, 1, 'shipped', '2025-01-10 14:20:00'),
  (3, 2, 'pending', '2025-01-11 09:05:00'),
  (4, 3, 'paid', '2025-01-15 18:40:00'),
  (5, 4, 'cancelled', '2025-02-01 12:00:00'),
  (6, 2, 'paid', '2025-02-03 16:30:00');

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
