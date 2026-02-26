# Corrections — 11. Sous-requêtes (requêtes imbriquées)

Préparation :
```sql
\c shop
```

## Exercice 1 — Moyenne globale (scalaire)

Énoncé : retourner les produits (`id`, `name`, `price`) dont le prix est **strictement supérieur** au prix moyen de tous les produits.

```sql
SELECT id, name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;
```

## Exercice 2 — Clients qui ont déjà commandé (`IN`)

Énoncé : retourner les clients (`id`, `email`) qui ont au moins une commande.

```sql
SELECT id, email
FROM customers
WHERE id IN (SELECT DISTINCT customer_id FROM orders)
ORDER BY id;
```

## Exercice 3 — Clients sans commande (`NOT EXISTS`)

Énoncé : retourner les clients (`id`, `email`) qui n'ont **aucune** commande.

```sql
SELECT c.id, c.email
FROM customers c
WHERE NOT EXISTS (
  SELECT 1
  FROM orders o
  WHERE o.customer_id = c.id
)
ORDER BY c.id;
```

## Exercice 4 — Produits jamais vendus (`NOT EXISTS`)

Énoncé : retourner les produits (`id`, `name`) qui n'apparaissent dans **aucune** ligne de commande (`order_items`).

```sql
SELECT p.id, p.name
FROM products p
WHERE NOT EXISTS (
  SELECT 1
  FROM order_items oi
  WHERE oi.product_id = p.id
)
ORDER BY p.id;
```

## Exercice 5 — Plus cher que la moyenne de sa catégorie (corrélée)

Énoncé : retourner les produits (`id`, `name`, `category_id`, `price`) dont le prix est supérieur à la moyenne des produits de **leur** catégorie.

```sql
SELECT p.id, p.name, p.category_id, p.price
FROM products p
WHERE p.price > (
  SELECT AVG(p2.price)
  FROM products p2
  WHERE p2.category_id = p.category_id
)
ORDER BY p.category_id, p.price DESC;
```

## Exercice 6 — Dernière commande de chaque client (corrélée)

Énoncé : retourner la dernière commande de chaque client :
- `customer_id`, `email`
- `order_id`, `ordered_at`, `status`

```sql
SELECT
  c.id AS customer_id,
  c.email,
  o.id AS order_id,
  o.ordered_at,
  o.status
FROM customers c
JOIN orders o ON o.customer_id = c.id
WHERE o.ordered_at = (
  SELECT MAX(o2.ordered_at)
  FROM orders o2
  WHERE o2.customer_id = c.id
)
ORDER BY c.id;
```

Remarque : si 2 commandes ont exactement la même `ordered_at`, cette requête peut renvoyer 2 lignes pour un client (rare avec un seed simple, mais possible).

## Exercice 7 — Commandes au-dessus de la moyenne (table dérivée)

Énoncé : retourner uniquement les commandes dont le total (`SUM(quantity * unit_price)`) est **strictement supérieur** à la moyenne des totaux des commandes.

```sql
SELECT t.order_id, t.total
FROM (
  SELECT oi.order_id, SUM(oi.quantity * oi.unit_price) AS total
  FROM order_items oi
  GROUP BY oi.order_id
) AS t
WHERE t.total > (
  SELECT AVG(t2.total)
  FROM (
    SELECT oi2.order_id, SUM(oi2.quantity * oi2.unit_price) AS total
    FROM order_items oi2
    GROUP BY oi2.order_id
  ) AS t2
)
ORDER BY t.total DESC;

```

## Exercice 8 — Client(s) qui a(ont) le plus dépensé (max via sous-requête) (***)

Énoncé : sur les commandes `paid` uniquement, retourner le(s) client(s) qui a(ont) dépensé le plus au total :
- `email`
- `total_paid`


Remarque `SELECT COALESCE(1, 0)` retourne 1 ici et sinon 0 dans l'exemple suivant: `SELECT COALESCE(NULL, 0)`

```sql
SELECT totals.email, totals.total_paid
FROM (
  SELECT
    c.email,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS total_paid
  FROM customers c
  JOIN orders o ON o.customer_id = c.id AND o.status = 'paid'
  JOIN order_items oi ON oi.order_id = o.id
  GROUP BY c.id, c.email
) AS totals
WHERE totals.total_paid = (
  SELECT MAX(t2.total_paid)
  FROM (
    SELECT
      c2.id,
      COALESCE(SUM(oi2.quantity * oi2.unit_price), 0) AS total_paid
    FROM customers c2
    JOIN orders o2 ON o2.customer_id = c2.id AND o2.status = 'paid'
    JOIN order_items oi2 ON oi2.order_id = o2.id
    GROUP BY c2.id
  ) AS t2
);
```
