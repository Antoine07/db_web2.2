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
- varient beaucoup selon le type d'objet (produits, événements…)
- changent souvent (schéma évolutif)

On garde le **cœur** en colonnes SQL (requêtes, contraintes, index), et le "reste" en JSON.

---

## `json` vs `jsonb` (important)

- `json` : stocke du texte JSON "tel quel" (peu utilisé en pratique)
- `jsonb` : stocke une forme binaire optimisée (indexation, opérateurs, perf en lecture)

Dans la majorité des cas : utilise **`jsonb`**.

---

## Quand *ne pas* utiliser JSONB ?

Si un champ est :
- filtré / trié en permanence
- jointé (FK)
- fortement contraint (CHECK/NOT NULL) et stable

→ mets une **colonne SQL** classique.

JSONB sert surtout pour des "extras" : metadata, attributs variables, payloads.

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

## Exemple 2 (NoSQL "léger") : metadata sur les commandes

Sur une commande, on peut stocker des infos variables :
- provider de paiement, coupon, ip, user-agent, source marketing…

```sql
ALTER TABLE orders
ADD COLUMN IF NOT EXISTS metadata jsonb DEFAULT '{}'::jsonb;
```

---

## Exemple : écrire une metadata (commande `paid`)

```sql
UPDATE orders
SET metadata = metadata || '{"paymentProvider":"stripe","coupon":"WELCOME10"}'::jsonb
WHERE id = 1;
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

## Modifier / ajouter une clé (merge avec `||`)

```sql
UPDATE products
SET attributes = COALESCE(attributes, '{}'::jsonb)
  || jsonb_build_object('material', 'cotton')
WHERE id = 6;
```

---

## Lire / extraire des valeurs : `->` vs `->>`

- `->` : extrait du JSON (type `jsonb`)
- `->>` : extrait du texte (type `text`)

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

## Filtrer sur une clé JSON (simple)

```sql
SELECT id, name
FROM products
WHERE attributes->>'color' = 'black';
```

---

## Filtrer par "contenu" (opérateur `@>`)

`@>` vérifie si un JSON contient un sous-document.

```sql
SELECT id, name
FROM products
WHERE attributes @> '{"material":"cotton"}'::jsonb;
```

---

## Tester l'existence d'une clé : `?`

```sql
SELECT id, name
FROM products
WHERE attributes ?? 'tags';
```

---

## Aller chercher un champ "profond" : `#>>`

Pour un chemin dans un document :

```sql
SELECT id, metadata #>> '{paymentProvider}' AS provider
FROM orders;
```

`#>>` renvoie du texte (pratique pour filtrer/afficher).

---

## Récap extraction : `->`, `->>`, `#>`, `#>>`

- `->` / `->>` : pour une clé (niveau 1)
- `#>` / `#>>` : pour un chemin (niveau N)

```sql
SELECT
  id,
  attributes->'tags' AS tags_json,
  attributes->>'color' AS color_text
FROM products
WHERE attributes IS NOT NULL;

SELECT id, metadata#>>'{paymentProvider}' AS provider_text
FROM orders;
```

---

## Tableaux JSONB : "déplier" avec `jsonb_array_elements`

Si on a un tableau `tags` :

```sql
SELECT p.id, p.name, t.tag
FROM products p
CROSS JOIN LATERAL jsonb_array_elements_text(p.attributes->'tags') AS t(tag)
WHERE p.attributes ?? 'tags';
```

---

## Tableaux JSONB : tester la présence d'une valeur

Sur un tableau, `?` fonctionne aussi pour tester un élément string :

```sql
SELECT id, name
FROM products
WHERE attributes->'tags' ?? 'cotton';
```

Alternative (pattern "contains" JSON) :

```sql
SELECT id, name
FROM products
WHERE attributes->'tags' @> '["cotton"]'::jsonb;
```

---

## Mettre à jour une clé précisément : `jsonb_set`

```sql
UPDATE orders
SET metadata = jsonb_set(metadata, '{coupon}', '"WELCOME10"', true)
WHERE id = 1;
```

---

## Mettre à jour une clé imbriquée : `jsonb_set` + chemin

```sql
UPDATE orders
SET metadata = jsonb_set(
  metadata,
  '{tracking,source}',
  '"instagram"',
  true
)
WHERE id = 1;
```

Ici, `tracking` est un objet, et on crée `tracking.source` si absent.

---

## Mettre à jour une clé imbriquée : `jsonb_set` + chemin avec l'option false


```sql
UPDATE orders
SET metadata = jsonb_set(
  metadata,
  '{tracking,source}',
  '"instagram"',
  false
)
WHERE id = 1;
```

Ici si tracking ou source n’existe pas →
👉 AUCUNE modification

---

## Supprimer une clé : opérateur `-`

```sql
UPDATE products
SET attributes = attributes - 'size'
WHERE id = 6;
```

- Supprimer plusieurs clés

```sql
UPDATE products
SET attributes = attributes - 'size' - 'color'
WHERE id = 6;
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

## Indexer du JSON (performance)

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

## Index JSONB : lequel choisir ?

- Si on fait beaucoup de requêtes `attributes @> ...` → **GIN** sur `attributes`
- Si on filtre toujours sur la même clé (ex: `brand`, `color`) → index d’expression sur `(attributes->>'color')`

Comme toujours : on indexe ce qu'on requête vraiment.

---

## Un minimum de "validation" avec `CHECK` (simple)

On peut imposer une règle sur une clé JSON :

```sql
ALTER TABLE orders
ADD CONSTRAINT chk_orders_payment_provider
CHECK (
  (metadata ? 'paymentProvider') IS FALSE
  OR metadata->>'paymentProvider' IN ('stripe', 'paypal')
);
```

---

## À retenir

- `JSONB` rend le schéma plus flexible, mais ne remplace pas le relationnel
- Si une donnée est souvent filtrée/triée/jointe → colonne SQL (ou index d'expression)
- JSONB est pratique pour des "extras" variables (attributs, metadata)

- [Exercices](https://github.com/Antoine07/db)
