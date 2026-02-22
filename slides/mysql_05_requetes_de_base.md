---
marp: true
title: "SQL (MySQL) — 05. Requêtes de base"
paginate: true
header: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
footer: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
---

# 05 — Requêtes de base

> Variante MySQL transcrite depuis le parcours PostgreSQL (adapter les syntaxes spécifiques).

## `SELECT`, filtres, tri, pagination

---

## Préparation

```sql
-- Dans psql :
\c shop
```

---

## Structure minimale d'une requête

```sql
SELECT colonnes
FROM table
WHERE condition
ORDER BY colonne
LIMIT 10 OFFSET 0;
```

---

## Ce que vous écrivez ≠ ce que PostgreSQL fait

Quand vous écrivez :

```sql
SELECT colonnes
FROM table
WHERE condition
ORDER BY colonne
LIMIT 10 OFFSET 0;
```

> **ce n'est pas l'ordre réel dans lequel PostgreSQL travaille**.
> C'est juste **l'ordre de rédaction obligatoire** de la requête.

---

## Ordre logique d'exécution SQL

```text
FROM
→ WHERE
→ SELECT
→ ORDER BY
→ LIMIT
```

- le filtrage (`WHERE`) se fait **avant** le calcul (`SELECT`)
- le tri (`ORDER BY`) se fait **après** le calcul


---

## Pourquoi c'est important ?

### Exemple classique qui pose problème

```sql
SELECT price * 1.2 AS price_ttc
FROM products
WHERE price_ttc > 5;
```

❌ **Erreur logique**
Pourquoi ? Parce que :

- `WHERE` est exécuté **avant** `SELECT`
- `price_ttc` **n'existe pas encore** au moment du WHERE

---

### Version correcte

```sql
SELECT price * 1.2 AS price_ttc
FROM products
WHERE price * 1.2 > 5;
```

>On remet le calcul directement dans le `WHERE`.

---

## Autre conséquence importante

Vous **pouvez** utiliser un alias dans :

```sql
ORDER BY price_ttc;
```

Pourquoi ?

- parce que `ORDER BY` est exécuté **après SELECT**

---

## Résumé 

### Ordre d'écriture (syntaxique)

```text
SELECT → FROM → WHERE → ORDER BY → LIMIT
```

### Ordre d'exécution (logique)

```text
FROM → WHERE → SELECT → ORDER BY → LIMIT
```

---


> L'ordre logique d'exécution explique pourquoi certains alias ne sont pas utilisables dans le WHERE.


---

## Sélectionner des colonnes

```sql
SELECT id, email, created_at
FROM customers;
```

Alias :
```sql
SELECT email AS customer_email
FROM customers;
```

---

## Filtrer avec `WHERE`

```sql
SELECT *
FROM orders
WHERE status = 'paid';
```

Opérateurs : `=`, `!=`, `>`, `<`, `>=`, `<=`

---

## Combiner des conditions

```sql
SELECT *
FROM products
WHERE price >= 20
  AND stock > 0;
```

```sql
SELECT *
FROM products
WHERE category_id = 1
   OR category_id = 2;
```

---

## Ensembles et intervalles

```sql
SELECT *
FROM products
WHERE category_id IN (1, 2, 3);
```

```sql
SELECT *
FROM orders
WHERE ordered_at BETWEEN '2025-01-01' AND '2025-01-31';
```

---

## Texte : `LIKE`

```sql
SELECT *
FROM customers
WHERE email LIKE '%@gmail.com';
```

- `%` : n'importe quelle suite de caractères
- `_` : un caractère

---

## Valeurs manquantes : `NULL`

La valeur `NULL` représente l'absence d'information (inconnue ou non applicable).

`NULL` ≠ `''` ≠ `0`

```sql
SELECT *
FROM customers
WHERE phone IS NULL;
```

---

## Trier et paginer

```sql
SELECT id, name, price
FROM products
ORDER BY price DESC, name ASC
LIMIT 20 OFFSET 0;
```

---

## Colonnes calculées

```sql
SELECT
  id,
  name,
  price,
  price * 1.2 AS price_with_vat
FROM products;
```

---

## `CASE` (catégoriser)

```sql
SELECT
  id,
  name,
  price,
  CASE
    WHEN price < 20 THEN 'cheap'
    WHEN price < 100 THEN 'standard'
    ELSE 'premium'
  END AS price_segment
FROM products;
```

---

## À faire (exercices)

- Exercices : `Exercices/05_requetes_de_base.md`
- [Dépôt](https://github.com/Antoine07/db)
