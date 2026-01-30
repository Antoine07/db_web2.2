# Exercices — 10. JSON dans PostgreSQL (`JSONB`)

## Préparation

Dans `psql` :
```sql
\c shop
```

## Exercice 1 — Évolution JSON

1) Vérifiez si une colonne `attributes` existe déjà sur `products` :
```sql
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'products'
  AND column_name = 'attributes';
```

2) Si elle n’existe pas, appliquez l’évolution :
```bash
psql -h 127.0.0.1 -p 5433 -U postgres -d shop -v ON_ERROR_STOP=1 -f data/shop_json_evolution_postgres.sql
```

## Exercice 2 — Lire des attributs

Écrivez une requête qui affiche :
- `id`, `name`
- `color` et `size` extraits de `attributes` (si présents)

## Exercice 3 — Filtrer

Filtrez les produits dont `attributes.color = 'black'`.

## Exercice 4 — Générer un document JSON

Générez un document JSON pour la commande `id = 1` qui contient :
- `order_id`, `status`, `ordered_at`
- un tableau `items` avec `product_id`, `quantity`, `unit_price`
