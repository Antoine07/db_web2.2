# Corrections — 01. Installation et setup PostgreSQL

## Exercice 1 — Vérification PostgreSQL

```sql
SELECT version();
```

Attendu :
- `version()` renvoie la version PostgreSQL.

## Exercice 2 — Import du schéma + données

```bash
docker compose exec postgres psql -U postgres -d shop -v ON_ERROR_STOP=1 -f /shared/postgres/seed.sql
docker compose exec postgres psql -U postgres -d shop
```

Vérification :
```sql
\dt
```

## Exercice 3 — Explorer la base

```sql
\d customers
\d orders
\d order_items
```

Pour voir précisément les contraintes (FK, CHECK, index) :
```sql
\d+ customers
\d+ orders
\d+ order_items
```

## Exercice 4 — Première requête

```sql
SELECT id, name, price FROM products;
SELECT id, email FROM customers;
SELECT id, status, ordered_at FROM orders;
```

## Exercice 5 — Sauver une session

Exemple de fichier `mes_requetes.sql` :

```sql
\c shop

SELECT id, name, stock FROM products WHERE stock > 0 ORDER BY stock DESC;
SELECT id, customer_id, status, ordered_at FROM orders ORDER BY ordered_at DESC LIMIT 10;
SELECT id, email FROM customers WHERE phone IS NULL;
```
