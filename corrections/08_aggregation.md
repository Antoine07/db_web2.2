# Corrections — 08. Agrégation

Préparation :
```sql
\c shop
```

## Exercice 1 — Compter

Énoncé :
1) Nombre total de clients  
2) Nombre total de commandes  
3) Nombre total de lignes de commande (`order_items`)

```sql
SELECT COUNT(*) AS nb_customers FROM customers;
SELECT COUNT(*) AS nb_orders FROM orders;
SELECT COUNT(*) AS nb_order_items FROM order_items;
```

## Exercice 2 — Commandes par statut

Énoncé : retourner `status` et `nb_orders`.

```sql
SELECT status, COUNT(*) AS nb_orders
FROM orders
GROUP BY status;
```

## Exercice 3 — Total par commande

Énoncé : pour chaque `order_id`, calculer `total = SUM(quantity * unit_price)`.

```sql
SELECT
  oi.order_id,
  SUM(oi.quantity * oi.unit_price) AS total
FROM order_items oi
GROUP BY oi.order_id;
```

## Exercice 4 — CA (commandes payées)

Énoncé : calculer le chiffre d’affaires total sur les commandes `paid` uniquement.

```sql
SELECT
  SUM(oi.quantity * oi.unit_price) AS revenue_paid
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
WHERE o.status = 'paid';
```

## Exercice 5 — CA par client (garder clients sans commande)

Énoncé : retourner pour chaque client :
- `email`
- nombre de commandes
- total payé (commandes `paid`)
En gardant les clients sans commande (valeurs à 0 si possible).

```sql
SELECT
  -- Email du client
  c.email,

  -- Nombre de commandes distinctes associées au client
  COUNT(DISTINCT o.id) AS nb_orders,

  -- Montant total payé :
  -- somme des (quantité × prix unitaire) uniquement pour les commandes payées
  -- COALESCE permet de retourner 0 si aucune commande payée n'existe
  COALESCE(
    SUM(
      CASE
        WHEN o.status = 'paid'
        THEN oi.quantity * oi.unit_price
        ELSE 0
      END
    ),
    0
  ) AS total_paid

FROM customers c

-- Jointure gauche pour conserver tous les clients,
-- même ceux qui n'ont jamais passé de commande
LEFT JOIN orders o
  ON o.customer_id = c.id

-- Jointure gauche pour inclure les lignes de commande
-- (nécessaires au calcul du montant total)
LEFT JOIN order_items oi
  ON oi.order_id = o.id

-- Agrégation par client
GROUP BY c.email;

```

## Exercice 6 — Top produits

Énoncé : retourner le top 3 des produits par quantité vendue (`SUM(quantity)`).

```sql
SELECT
  p.id,
  p.name,
  SUM(oi.quantity) AS qty_sold
FROM order_items oi
JOIN products p ON p.id = oi.product_id
GROUP BY p.id, p.name
ORDER BY qty_sold DESC
LIMIT 3;
```

## Exercice 7 — `HAVING`

Énoncé : retourner les clients ayant dépensé au moins 100 (sur commandes payées).

```sql
SELECT
  c.email,
  SUM(oi.quantity * oi.unit_price) AS total_paid
FROM customers c
JOIN orders o ON o.customer_id = c.id
JOIN order_items oi ON oi.order_id = o.id
WHERE o.status = 'paid'
GROUP BY c.id, c.email
HAVING total_paid >= 100;
```
