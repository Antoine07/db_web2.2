# Exercices — 08. Agrégation

## Préparation

```sql
-- Dans psql :
\c shop
```

## Exercice 1 — Compter

1) Nombre total de clients  
2) Nombre total de commandes  
3) Nombre total de lignes de commande (`order_items`)

## Exercice 2 — Commandes par statut

Retournez :
- `status`
- `nb_orders`

## Exercice 3 — Total par commande

Pour chaque `order_id`, calculez :
- `total = SUM(quantity * unit_price)`

## Exercice 4 — Chiffre d’affaires (commandes payées)

Calculez le CA total sur les commandes `paid` uniquement.

Indice : `orders` + `order_items`.

## Exercice 5 — CA par client

Retournez pour chaque client :
- `email`
- nombre de commandes
- total payé (somme des totaux des commandes payées)

Garder les clients sans commande (valeurs à 0 si possible).

Remarque `COALESCE` permet de retourner 0 si aucune commande payée n'existe

## Exercice 6 — Top produits

Retournez le top 3 des produits par quantité vendue (`SUM(quantity)`).

## Exercice 7 — Filtrer avec `HAVING`

Retournez les clients ayant dépensé au moins 100 (sur commandes payées).
