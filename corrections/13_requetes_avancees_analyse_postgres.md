# Corrections — 13. Requêtes avancées d'analyse (PostgreSQL)

Préparation :
```sql
\c shop
```

## Exercice 1 — Total par commande payée

```sql
SELECT
  o.id AS order_id,
  o.ordered_at,
  SUM(oi.quantity * oi.unit_price) AS total_order
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
WHERE o.status = 'paid'
GROUP BY o.id, o.ordered_at
ORDER BY total_order DESC;
```

## Exercice 2 — CA journalier

```sql
SELECT
  DATE(o.ordered_at) AS jour,
  SUM(oi.quantity * oi.unit_price) AS ca_jour
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
WHERE o.status = 'paid'
GROUP BY DATE(o.ordered_at)
ORDER BY jour;
```

## Exercice 3 — CA cumulé

```sql
WITH daily AS (
  SELECT
    DATE(o.ordered_at) AS jour,
    SUM(oi.quantity * oi.unit_price) AS ca_jour
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.id
  WHERE o.status = 'paid'
  GROUP BY DATE(o.ordered_at)
)
SELECT
  jour,
  ca_jour,
  SUM(ca_jour) OVER (ORDER BY jour) AS ca_cumule
FROM daily
ORDER BY jour;
```

## Exercice 4 — Moyenne mobile 3 jours

```sql
WITH daily AS (
  SELECT
    DATE(o.ordered_at) AS jour,
    SUM(oi.quantity * oi.unit_price) AS ca_jour
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.id
  WHERE o.status = 'paid'
  GROUP BY DATE(o.ordered_at)
)
SELECT
  jour,
  ca_jour,
  ROUND(AVG(ca_jour) OVER (
    ORDER BY jour
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ), 2) AS avg_3j
FROM daily
ORDER BY jour;
```

## Exercice 5 — Classement clients (CA payé)

```sql
SELECT
  c.id AS customer_id,
  c.email,
  SUM(oi.quantity * oi.unit_price) AS total_paid,
  DENSE_RANK() OVER (
    ORDER BY SUM(oi.quantity * oi.unit_price) DESC
  ) AS rang_ca
FROM customers c
JOIN orders o ON o.customer_id = c.id
JOIN order_items oi ON oi.order_id = o.id
WHERE o.status = 'paid'
GROUP BY c.id, c.email
ORDER BY rang_ca, c.id;
```

## Exercice 6 — Meilleur client de chaque mois

```sql
WITH month_customer AS (
  SELECT
    DATE_TRUNC('month', o.ordered_at)::date AS mois,
    c.id AS customer_id,
    c.email,
    SUM(oi.quantity * oi.unit_price) AS total_paid
  FROM customers c
  JOIN orders o ON o.customer_id = c.id
  JOIN order_items oi ON oi.order_id = o.id
  WHERE o.status = 'paid'
  GROUP BY DATE_TRUNC('month', o.ordered_at)::date, c.id, c.email
),
ranked AS (
  SELECT
    mois,
    customer_id,
    email,
    total_paid,
    ROW_NUMBER() OVER (
      PARTITION BY mois
      ORDER BY total_paid DESC, customer_id
    ) AS rn
  FROM month_customer
)
SELECT mois, customer_id, email, total_paid
FROM ranked
WHERE rn = 1
ORDER BY mois;
```

## Exercice 7 — Part de CA par catégorie

```sql
WITH by_cat AS (
  SELECT
    cat.name AS categorie,
    SUM(oi.quantity * oi.unit_price) AS ca
  FROM categories cat
  JOIN products p ON p.category_id = cat.id
  JOIN order_items oi ON oi.product_id = p.id
  JOIN orders o ON o.id = oi.order_id
  WHERE o.status = 'paid'
  GROUP BY cat.name
)
SELECT
  categorie,
  ca,
  ROUND(100.0 * ca / SUM(ca) OVER (), 2) AS part_ca_pct
FROM by_cat
ORDER BY ca DESC;
```

## Exercice 8 — Segmentation clients en quartiles

```sql
WITH customer_totals AS (
  SELECT
    c.email,
    SUM(oi.quantity * oi.unit_price) AS total_paid
  FROM customers c
  JOIN orders o ON o.customer_id = c.id
  JOIN order_items oi ON oi.order_id = o.id
  WHERE o.status = 'paid'
  GROUP BY c.id, c.email
)
SELECT
  email,
  total_paid,
  NTILE(4) OVER (ORDER BY total_paid DESC) AS quartile
FROM customer_totals
ORDER BY total_paid DESC;
```

## Exercice 9 — Variation mensuelle du CA

```sql
WITH month_ca AS (
  SELECT
    DATE_TRUNC('month', o.ordered_at)::date AS mois,
    SUM(oi.quantity * oi.unit_price) AS ca_mois
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.id
  WHERE o.status = 'paid'
  GROUP BY DATE_TRUNC('month', o.ordered_at)::date
)
SELECT
  mois,
  ca_mois,
  LAG(ca_mois) OVER (ORDER BY mois) AS ca_mois_prec,
  ca_mois - LAG(ca_mois) OVER (ORDER BY mois) AS delta_ca,
  ROUND(
    100.0 * (ca_mois - LAG(ca_mois) OVER (ORDER BY mois))
    / NULLIF(LAG(ca_mois) OVER (ORDER BY mois), 0),
    2
  ) AS delta_pct
FROM month_ca
ORDER BY mois;
```

## Exercice 10 — Commandes au-dessus de la moyenne du mois

```sql
WITH order_totals AS (
  SELECT
    DATE_TRUNC('month', o.ordered_at)::date AS mois,
    o.id AS order_id,
    SUM(oi.quantity * oi.unit_price) AS total_order
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.id
  WHERE o.status = 'paid'
  GROUP BY DATE_TRUNC('month', o.ordered_at)::date, o.id
),
scored AS (
  SELECT
    mois,
    order_id,
    total_order,
    AVG(total_order) OVER (PARTITION BY mois) AS avg_mois
  FROM order_totals
)
SELECT mois, order_id, total_order, ROUND(avg_mois, 2) AS avg_mois
FROM scored
WHERE total_order > avg_mois
ORDER BY mois, total_order DESC;
```
