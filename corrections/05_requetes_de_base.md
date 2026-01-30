# Corrections — 05. Requêtes de base

Préparation :
```sql
\c shop
```

## Exercice 1 — `SELECT` simple

Énoncé :
1) Listez tous les produits (`id`, `name`, `price`)  
2) Listez tous les clients (`id`, `email`, `created_at`)

```sql
SELECT id, name, price FROM products;
SELECT id, email, created_at FROM customers;
```

## Exercice 2 — Filtres

Énoncé :
1) Produits avec un stock strictement supérieur à 50  
2) Produits dont le prix est entre 20 et 100  
3) Commandes au statut `paid`

```sql
SELECT id, name, stock FROM products WHERE stock > 50;

SELECT id, name, price
FROM products
WHERE price BETWEEN 20 AND 100;

SELECT id, customer_id, status, ordered_at
FROM orders
WHERE status = 'paid';
```

## Exercice 3 — `IN` / `LIKE`

Énoncé :
1) Produits dont la `category_id` est dans (1, 3)  
2) Clients dont l'email se termine par `@demo.test`  
3) Produits dont le `sku` commence par `SHOE-`

```sql
SELECT id, name, category_id
FROM products
WHERE category_id IN (1, 3);

SELECT id, email
FROM customers
WHERE email LIKE '%@demo.test';

SELECT id, sku, name
FROM products
WHERE sku LIKE 'SHOE-%';
```

## Exercice 4 — `NULL`

Énoncé :
1) Clients sans téléphone  
2) Clients avec téléphone

```sql
SELECT id, email FROM customers WHERE phone IS NULL;
SELECT id, email, phone FROM customers WHERE phone IS NOT NULL;
```

## Exercice 5 — Tri + pagination

Énoncé :
1) 3 produits les plus chers  
2) 3 produits les moins chers  
3) Produits triés par `category_id` puis par `price` décroissant

```sql
SELECT id, name, price
FROM products
ORDER BY price DESC
LIMIT 3;

SELECT id, name, price
FROM products
ORDER BY price ASC
LIMIT 3;

SELECT id, name, category_id, price
FROM products
ORDER BY category_id ASC, price DESC;
```

## Exercice 6 — Colonnes calculées

Énoncé :
1) Affichez `price_with_vat = price * 1.2` pour chaque produit  
2) Affichez `full_name = CONCAT(first_name, ' ', last_name)` pour chaque client

```sql
SELECT id, name, price, (price * 1.2) AS price_with_vat
FROM products;

SELECT id, first_name, last_name, CONCAT(first_name, ' ', last_name) AS full_name
FROM customers;
```

## Exercice 7 — `CASE`

Énoncé : créer une colonne `stock_label` :
- `out` si `stock = 0`
- `low` si `stock` entre 1 et 20
- `ok` si `stock > 20`

```sql
SELECT
  id,
  name,
  stock,
  CASE
    WHEN stock = 0 THEN 'out'
    WHEN stock BETWEEN 1 AND 20 THEN 'low'
    ELSE 'ok'
  END AS stock_label
FROM products;
```

## Exercice 8 — Calculs arithmétiques simples

Énoncé (sur `products`) :
1) Affichez `price_ht = price / 1.2`  
2) Affichez `stock_value = stock * price`

```sql
SELECT
  id,
  name,
  price,
  price / 1.2 AS price_ht,
  stock,
  stock * price AS stock_value
FROM products;
```

---

## Exercice 9 — Calculs conditionnels (`CASE`)

Énoncé (sur `products`) : créer une colonne `price_range` :
- `cheap` si `price < 20`
- `medium` si `price` entre 20 et 100
- `expensive` si `price > 100`

```sql
SELECT
  id,
  name,
  price,
  CASE
    WHEN price < 20 THEN 'cheap'
    WHEN price BETWEEN 20 AND 100 THEN 'medium'
    ELSE 'expensive'
  END AS price_range
FROM products;
```

---

## Exercice 10 — Calculs sur dates

Énoncé (sur `orders`) :
1) Affichez le jour de la commande  
2) Affichez le mois de la commande  
3) Affichez l’année de la commande

```sql
SELECT
  id,
  ordered_at,
  EXTRACT(DAY FROM ordered_at)   AS order_day,
  EXTRACT(MONTH FROM ordered_at) AS order_month,
  EXTRACT(YEAR FROM ordered_at)  AS order_year
FROM orders;
```

---

## Exercice 11 — Calculs sur chaînes

Énoncé (sur `customers`) :
1) Longueur de l’email  
2) Domaine de l’email (après `@`)  
3) Email en majuscules

```sql
SELECT
  id,
  email,
  LENGTH(email) AS email_length,
  split_part(email, '@', 2) AS email_domain,
  UPPER(email) AS email_upper
FROM customers;
```

---

## Exercice 12 — Logique booléenne

Énoncé (sur `products`) :
1) Colonne `is_available` : `1` si `stock > 0`, sinon `0`  
2) Colonne `is_expensive` : `1` si `price > 100`, sinon `0`

```sql
SELECT
  id,
  name,
  stock,
  CASE WHEN stock > 0 THEN 1 ELSE 0 END AS is_available,
  price,
  CASE WHEN price > 100 THEN 1 ELSE 0 END AS is_expensive
FROM products;
```

---

## Exercice 13 — Calculs combinés

Énoncé (sur `order_items`) :
1) Affichez `line_total = quantity * unit_price`  
2) Affichez une colonne `bulk_order` : `yes` si `quantity >= 3`, sinon `no`

```sql
SELECT
  order_id,
  product_id,
  quantity,
  unit_price,
  quantity * unit_price AS line_total,
  CASE
    WHEN quantity >= 3 THEN 'yes'
    ELSE 'no'
  END AS bulk_order
FROM order_items;
```
