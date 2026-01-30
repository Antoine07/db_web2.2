# Corrections — 10. JSON dans PostgreSQL (`JSONB`)

## Exercice 1 — Évolution JSON

Vérifier si la colonne existe :
```sql
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'products'
  AND column_name = 'attributes';
```

Appliquer l’évolution (si besoin) :
```bash
psql -h 127.0.0.1 -p 5433 -U postgres -d shop -v ON_ERROR_STOP=1 -f data/shop_json_evolution_postgres.sql
```

## Exercice 2 — Lire des attributs

```sql
SELECT
  id,
  name,
  attributes->>'color' AS color,
  attributes->>'size' AS size
FROM products
ORDER BY id;
```

## Exercice 3 — Filtrer

```sql
SELECT id, name
FROM products
WHERE attributes->>'color' = 'black'
ORDER BY id;
```

## Exercice 4 — Générer un document JSON

```sql
SELECT jsonb_build_object(
  'order_id', o.id,
  'status', o.status,
  'ordered_at', o.ordered_at,
  'items', jsonb_agg(
    jsonb_build_object(
      'product_id', oi.product_id,
      'quantity', oi.quantity,
      'unit_price', oi.unit_price
    )
    ORDER BY oi.product_id
  )
) AS order_doc
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
WHERE o.id = 1
GROUP BY o.id;
```

