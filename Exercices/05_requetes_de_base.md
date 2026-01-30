# Exercices — 05. Requêtes de base

## Préparation

Assurez-vous d'avoir importé la base :
- `data/shop_schema_postgres.sql`
- `data/shop_seed_postgres.sql`

Dans `psql` :
```sql
\c shop
```

## Exercice 1 — `SELECT` simple

1) Listez tous les produits (`id`, `name`, `price`)  
2) Listez tous les clients (`id`, `email`, `created_at`)

## Exercice 2 — Filtres

1) Produits avec un stock strictement supérieur à 50  
2) Produits dont le prix est entre 20 et 100  
3) Commandes au statut `paid`

## Exercice 3 — `IN` / `LIKE`

1) Produits dont la `category_id` est dans (1, 3)  
2) Clients dont l'email se termine par `@demo.test`  
3) Produits dont le `sku` commence par `SHOE-`

## Exercice 4 — `NULL`

1) Clients sans téléphone  
2) Clients avec téléphone (l'inverse)

## Exercice 5 — Tri + pagination

1) 3 produits les plus chers  
2) 3 produits les moins chers  
3) Produits triés par `category_id` puis par `price` décroissant

## Exercice 6 — Colonnes calculées

1) Affichez `price_with_vat = price * 1.2` pour chaque produit  
2) Affichez `full_name = CONCAT(first_name, ' ', last_name)` pour chaque client

## Exercice 7 — `CASE`

Créez une colonne `stock_label` :
- `out` si `stock = 0`
- `low` si `stock` entre 1 et 20
- `ok` si `stock > 20`

## Exercice 8 — Calculs arithmétiques simples

Sur `products` :

1. Affichez `price_ht = price / 1.2`
2. Affichez `stock_value = stock * price`


## Exercice 9 — Calculs conditionnels (`CASE`)

Sur `products`, créez une colonne `price_range` :

* `cheap` si `price < 20`
* `medium` si `price` entre 20 et 100
* `expensive` si `price > 100`


## Exercice 10 — Calculs sur dates

Sur `orders` :

1. Affichez le jour de la commande
2. Affichez le mois de la commande
3. Affichez l’année de la commande


## Exercice 11 — Calculs sur chaînes

Sur `customers` :

1. Longueur de l’email
2. Domaine de l’email (après `@`)
3. Email en majuscules


## Exercice 12 — Logique booléenne

Sur `products` :

1. Colonne `is_available` :

* `1` si `stock > 0`
* `0` sinon

2. Colonne `is_expensive` :

* `1` si `price > 100`
* `0` sinon


## Exercice 13 — Calculs combinés

Sur `order_items` :

1. Affichez `line_total = quantity * unit_price`
2. Affichez une colonne `bulk_order` :

* `yes` si `quantity >= 3`
* `no` sinon
