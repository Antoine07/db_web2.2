---
marp: true
title: "SQL (PostgreSQL) — 10. JSON dans PostgreSQL (SQL + NoSQL)"
paginate: true
header: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
footer: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
---

# 10 — JSON dans PostgreSQL
## `JSONB` : quand un SGBD SQL fait aussi du "document"

---

## Objectif

- Comprendre quand utiliser une colonne `JSONB`
- Savoir écrire / lire / filtrer du JSON
- Voir une **évolution du schéma** sur le fil rouge `shop`

---

## Pourquoi du JSONB ?

Utile quand certaines propriétés :
- varient beaucoup selon le type d’objet (produits, événements…)
- changent souvent (schéma évolutif)

On garde le **cœur** en colonnes SQL (requêtes, contraintes, index), et le "reste" en JSON.

---

## Évolution du fil rouge `shop`

On ajoute une colonne `attributes` sur `products` et on remplit quelques exemples :

```bash
psql -h 127.0.0.1 -p 5433 -U postgres -d shop -v ON_ERROR_STOP=1 -f data/shop_json_evolution_postgres.sql
```

Ou manuellement :

```sql
ALTER TABLE products
  ADD COLUMN attributes JSONB NULL;
```

---

## Vérifier le résultat

```sql
SELECT id, name, attributes
FROM products
WHERE attributes IS NOT NULL
ORDER BY id;
```

---

## Écrire du JSON (`jsonb_build_object`, `jsonb_build_array`)

```sql
UPDATE products
SET attributes = jsonb_build_object(
  'color', 'black',
  'size', 'M',
  'tags', jsonb_build_array('cotton', 'basic')
)
WHERE id = 6;
```

---

## Modifier / ajouter une clé (merge)

```sql
UPDATE products
SET attributes = COALESCE(attributes, '{}'::jsonb)
  || jsonb_build_object('material', 'cotton')
WHERE id = 6;
```

---

## Lire / extraire des valeurs

```sql
SELECT
  id,
  name,
  attributes->>'color' AS color,
  attributes->>'size' AS size
FROM products
WHERE attributes IS NOT NULL;
```

---

## Filtrer sur du JSON

```sql
SELECT id, name
FROM products
WHERE attributes->>'color' = 'black';
```

---

## Produire un "document" JSON à partir de SQL

Exemple : retourner une commande avec ses lignes sous forme JSON :

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

---

## Indexer du JSON (optionnel)

2 approches courantes :

Index "générique" (recherches dans le document) :
```sql
CREATE INDEX idx_products_attributes_gin
ON products
USING gin (attributes);
```

Index sur une clé précise (filtre fréquent) :
```sql
CREATE INDEX idx_products_brand
ON products ((attributes->>'brand'));
```

---

## À retenir

- `JSONB` rend le schéma plus flexible, mais ne remplace pas le relationnel
- Si une donnée est souvent filtrée/triée/jointe → colonne SQL (ou index d'expression)
- JSONB est pratique pour des "extras" variables (attributs, metadata)
