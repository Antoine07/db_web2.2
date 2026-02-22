---
marp: true
title: "SQL (MySQL) — 13. Requêtes avancées d'analyse"
paginate: true
header: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
footer: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
---

# Requêtes avancées orientées analyse de données

> Variante MySQL transcrite depuis le parcours PostgreSQL (adapter les syntaxes spécifiques).

## CTE + fenêtres + segmentation

```sql
-- 1) Top clients sur 90 jours (ranking)
SELECT c.id, c.email,
       SUM(oi.quantity * oi.unit_price) AS ca_90j,
       DENSE_RANK() OVER (ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS rang_ca
FROM customers c
JOIN orders o ON o.customer_id = c.id
JOIN order_items oi ON oi.order_id = o.id
WHERE o.status = 'paid'
  AND o.created_at >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY c.id, c.email
ORDER BY rang_ca
LIMIT 10;

-- 2) CA journalier + cumul glissant 7 jours
WITH daily AS (
  SELECT DATE(o.created_at) AS jour, SUM(oi.quantity * oi.unit_price) AS ca
  FROM orders o JOIN order_items oi ON oi.order_id = o.id
  WHERE o.status = 'paid'
  GROUP BY DATE(o.created_at)
)
SELECT jour, ca,
       SUM(ca) OVER (ORDER BY jour ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS ca_7j
FROM daily
ORDER BY jour;

-- 3) Part de CA par catégorie + quartiles de performance
WITH by_cat AS (
  SELECT cat.name AS categorie, SUM(oi.quantity * oi.unit_price) AS ca
  FROM categories cat
  JOIN products p ON p.category_id = cat.id
  JOIN order_items oi ON oi.product_id = p.id
  JOIN orders o ON o.id = oi.order_id
  WHERE o.status = 'paid'
  GROUP BY cat.name
)
SELECT categorie, ca,
       ROUND(100.0 * ca / SUM(ca) OVER (), 2) AS part_ca_pct,
       NTILE(4) OVER (ORDER BY ca DESC) AS quartile
FROM by_cat
ORDER BY ca DESC;
```
