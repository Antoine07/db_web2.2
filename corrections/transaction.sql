BEGIN;

WITH new_order AS (
  INSERT INTO orders (customer_id, status, ordered_at)
  VALUES (1, 'pending', NOW())
  RETURNING id
),
items AS (
  SELECT *
  FROM (
    VALUES
      (1, 2, 14.00::numeric), -- product_id, quantity, unit_price
      (2, 1, 65.00::numeric)
  ) AS v(product_id, quantity, unit_price)
),
inserted_items AS (
  INSERT INTO order_items (order_id, product_id, quantity, unit_price)
  SELECT new_order.id, items.product_id, items.quantity, items.unit_price
  FROM new_order
  CROSS JOIN items
  RETURNING product_id, quantity
)
UPDATE products p
SET stock = p.stock - inserted_items.quantity
FROM inserted_items
WHERE p.id = inserted_items.product_id;

COMMIT;