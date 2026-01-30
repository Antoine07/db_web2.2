---
marp: true
title: "SQL (PostgreSQL) — 11. Sous-requêtes (requêtes imbriquées)"
paginate: true
header: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
footer: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
---

# 11 — Sous-requêtes
## Requêtes imbriquées (subqueries)

---

## Objectif

- Comprendre **quand** utiliser une sous-requête vs une jointure
- Savoir écrire des sous-requêtes :
  - scalaires (1 valeur)
  - listes (`IN`)
  - d'existence (`EXISTS`)
  - corrélées (dépendent de la ligne courante)
  - "tables dérivées" (sous-requête dans `FROM`)

---

## Rappel : fil rouge `shop`

Tables :
- `customers`, `orders`, `order_items`, `products`, `categories`

---

Schéma UML :

![Ouvrir le SVG](https://antoine07.github.io/db_web2.2/assets/boutique_uml.svg)

---

## Qu'est-ce qu'une sous-requête ?

Une requête SQL **à l'intérieur** d'une autre requête.

Exemples d'emplacements :
- `WHERE ... (SELECT ...)`
- `SELECT ..., (SELECT ...) AS x`
- `FROM (SELECT ...) AS t`

---

## Sous-requête scalaire (1 valeur)

Produits plus chers que la moyenne :

```sql
SELECT id, name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products);
```

---

## Sous-requête "liste" + `IN`

Clients qui ont déjà commandé :

```sql
SELECT id, email
FROM customers
WHERE id IN (SELECT DISTINCT customer_id FROM orders);
```

---

## `EXISTS` (recommandé pour "au moins 1")

Clients qui ont au moins 1 commande payée :

```sql
SELECT c.id, c.email
FROM customers c
WHERE EXISTS (
  SELECT 1
  FROM orders o
  WHERE o.customer_id = c.id
    AND o.status = 'paid'
);
```

---

## `NOT EXISTS` (recommandé pour "aucun")

Clients sans commande :

```sql
SELECT c.id, c.email
FROM customers c
WHERE NOT EXISTS (
  SELECT 1
  FROM orders o
  WHERE o.customer_id = c.id
);
```

---

## Sous-requête corrélée (attention)

>La sous-requête est recalculée pour chaque ligne de la requête principale.

Produits plus chers que la moyenne de **leur catégorie** :

```sql
SELECT p.id, p.name, p.category_id, p.price
FROM products p
WHERE p.price > (
  SELECT AVG(p2.price)
  FROM products p2
  WHERE p2.category_id = p.category_id
);
```

---

## Solution plus optimisé

```sql

SELECT p.id, p.name, p.category_id, p.price
FROM products p
JOIN (
  SELECT category_id, AVG(price) AS avg_price
  FROM products
  GROUP BY category_id
) avg_cat
  ON avg_cat.category_id = p.category_id
WHERE p.price > avg_cat.avg_price;
```

<details> <summary><strong>Cliquer pour voir la réponse</strong></summary>
  Parce que la moyenne est calculée une seule fois par catégorie
</details>

---

## "Table dérivée" (sous-requête dans `FROM`)

Total par commande, puis filtrer :

```sql
SELECT t.order_id, t.total
FROM (
  SELECT oi.order_id, SUM(oi.quantity * oi.unit_price) AS total
  FROM order_items oi
  GROUP BY oi.order_id
) AS t
WHERE t.total >= 100
ORDER BY t.total DESC;
```

---

## Piège : `NOT IN` et les `NULL`

Règle pratique :
- pour "aucun", préférez **`NOT EXISTS`** (souvent plus robuste)
- `NOT IN (SELECT ...)` peut donner des résultats surprenants si la sous-requête peut renvoyer `NULL`

---

## Sous-requête vs jointure : quoi choisir ?

- **Jointure** : ramener des colonnes de plusieurs tables (et agrégation)
- **Sous-requête** : calculer un critère (moyenne, max, existence…) et filtrer
- En pratique : on peut souvent faire les deux ; choisissez la version la plus lisible

---

## À faire (exercices)

- Exercices : `Exercices/11_sous_requetes.md`
