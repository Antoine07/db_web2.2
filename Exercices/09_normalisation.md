# Exercices — 09. Normalisation (1NF → 3NF)

## Objectif

Prendre un exemple "sale" et proposer un schéma normalisé + ses clés/contraintes.

## Données de départ (dénormalisées)

On a une table unique `sales_flat` :

- `order_id`
- `ordered_at`
- `customer_email`
- `customer_name`
- `customer_phone`
- `product_sku`
- `product_name`
- `category_name`
- `unit_price`
- `quantity`
- `shipping_postal_code`
- `shipping_city`
- `region_name`

Hypothèses :
- un `order_id` appartient à un seul client
- une commande contient plusieurs produits
- un `product_sku` correspond à un seul produit
- un `category_name` correspond à une seule catégorie
- un `shipping_postal_code` détermine `shipping_city` et `region_name`

## Exercice 1 — Problèmes

1) Citez 5 colonnes qui vont se répéter (et pourquoi)  
2) Donnez 2 anomalies possibles (update/insert/delete)

## Exercice 2 — 1NF

1) Repérez les groupes répétés  
2) Proposez une première séparation en tables "commande" et "lignes de commande"  
3) Donnez les PK attendues

## Exercice 3 — 2NF

Dans la table de lignes (clé composée), identifiez les colonnes qui ne dépendent que d’une partie de la clé.

1) Quelles colonnes dépendent uniquement de `product_sku` ?  
2) Déplacez-les dans une table `products`

## Exercice 4 — 3NF

À partir de `shipping_postal_code -> (shipping_city, region_name)` :

1) Proposez une table `postal_codes` (ou similaire)  
2) Modifiez la table de commandes pour ne garder qu’une FK vers cette table

## Exercice 5 — Schéma final

Proposez un schéma 3NF minimal avec :
- `customers`
- `orders`
- `order_items`
- `products`
- `categories`
- `postal_codes` (ou équivalent)

Pour chaque table, donnez :
- PK
- FK
- 2 contraintes de qualité (ex: `NOT NULL`, `UNIQUE`, `CHECK`)

## Exercice 6 — DDL

Écrivez les `CREATE TABLE` (PostgreSQL) pour votre proposition.
