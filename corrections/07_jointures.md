# Corrections — 07. Jointures

Préparation :
```sql
\c shop
```

## Exercice 1 — Commandes avec email client

Énoncé : retourner la liste des commandes avec :
- `order_id`, `ordered_at`, `status`
- `customer_email`

```sql
SELECT
  o.id AS order_id,
  o.ordered_at,
  o.status,
  c.email AS customer_email
FROM orders o
JOIN customers c ON c.id = o.customer_id
ORDER BY o.ordered_at DESC;
```

## Exercice 2 — Détail d’une commande (`order_id = 4`)

Énoncé : pour `order_id = 4`, afficher :
- le nom des produits
- la quantité
- le prix unitaire (`unit_price`)

```sql
SELECT
  p.name AS product_name,
  oi.quantity,
  oi.unit_price
FROM order_items oi
JOIN products p ON p.id = oi.product_id
WHERE oi.order_id = 4;
```

## Exercice 3 — Clients + nb commandes (garder les clients sans commande)

Énoncé : afficher tous les clients (email) + le nombre de commandes associées, en gardant les clients sans commande.

```sql
SELECT
  c.email,
  COUNT(o.id) AS nb_orders
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.id
GROUP BY c.id, c.email;
```

## Exercice 4 — Produits et catégories

Énoncé : lister les produits avec :
- `product_name`, `price`
- `category_name`

```sql
SELECT
  p.name AS product_name,
  p.price,
  cat.name AS category_name
FROM products p
JOIN categories cat ON cat.id = p.category_id;
```

## Exercice 5 — Piège `WHERE` vs `ON`

Énoncé : afficher tous les clients et, si elles existent, leurs commandes **payées** :
1) via `LEFT JOIN` + filtre dans `WHERE`  
2) puis via `LEFT JOIN` + filtre dans le `ON`

Filtre en `WHERE` (perd les clients sans commande payée) :
```sql
SELECT c.email, o.id
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.id
WHERE o.status = 'paid';
```

Filtre dans le `ON` (garde tous les clients) :
```sql
SELECT c.email, o.id
FROM customers c
LEFT JOIN orders o
  ON o.customer_id = c.id
 AND o.status = 'paid';
```

## Exercice 6 — Commandes “vides”

Énoncé : retourner les commandes qui n’ont **aucune** ligne dans `order_items`.

```sql
SELECT o.id AS order_id
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.id
WHERE oi.order_id IS NULL;
```

## Exercice 7 — Toutes les commandes d’un client (`customer_id = 1`)

Énoncé : pour un client donné, retourner toutes ses commandes avec le détail des produits :
- `order_id`, `ordered_at`, `status`
- `product_name`, `quantity`, `unit_price`
- `line_total = quantity * unit_price`

```sql
SELECT
  o.id AS order_id,
  o.ordered_at,
  o.status,
  p.name AS product_name,
  oi.quantity,
  oi.unit_price,
  (oi.quantity * oi.unit_price) AS line_total
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id
WHERE o.customer_id = 1
ORDER BY o.ordered_at DESC, o.id DESC, p.id ASC;
```
