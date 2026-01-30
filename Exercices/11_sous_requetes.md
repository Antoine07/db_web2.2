# Exercices — 11. Sous-requêtes (requêtes imbriquées)

## Préparation

```sql
-- Dans psql :
\c shop
```

## Exercice 1 — Moyenne globale (sous-requête scalaire)

Retournez les produits (`id`, `name`, `price`) dont le prix est **strictement supérieur** au prix moyen de tous les produits.

```sql
SELECT id, name, price 
FROM products 
WHERE price > ( SELECT AVG(price) FROM products ) ;
```


## Exercice 2 — Clients qui ont déjà commandé (`IN`)

Retournez les clients (`id`, `email`) qui ont au moins une commande.

Indice : `WHERE id IN (SELECT ...)`.

```sql
SELECT id, email FROM customers WHERE  id IN ( SELECT DISTINCT customer_id FROM orders ) ;
```

## Exercice 3 — Clients sans commande (`NOT EXISTS`)

Retournez les clients (`id`, `email`) qui n’ont **aucune** commande.

Indice : `WHERE NOT EXISTS (SELECT 1 FROM orders ... )`.


```sql
SELECT id, email 
FROM customers c 
WHERE NOT EXISTS ( 
 SELECT 1 
 FROM orders o 
 WHERE o.customer_id = c.id  
);
```


## Exercice 4 — Produits jamais vendus (`NOT EXISTS`)

Retournez les produits (`id`, `name`) qui n’apparaissent dans **aucune** ligne de commande (`order_items`).


```sql


```


## Exercice 5 — Plus cher que la moyenne de sa catégorie (corrélée)

Retournez les produits (`id`, `name`, `category_id`, `price`) dont le prix est supérieur à la moyenne des produits de **leur** catégorie.

## Exercices à faire chez vous et à rendre le dernier jour

## Exercice 6 — Dernière commande de chaque client (corrélée)

Retournez la dernière commande de chaque client :
- `customer_id`, `email`
- `order_id`, `ordered_at`, `status`

Indice : comparez `ordered_at` avec un `MAX(ordered_at)` dans une sous-requête corrélée.

## Exercice 7 — Commandes “au-dessus de la moyenne” (table dérivée)

1) Calculez le total de chaque commande : `SUM(quantity * unit_price)`  
2) Calculez la moyenne de ces totaux  
3) Retournez uniquement les commandes dont le total est **strictement supérieur** à cette moyenne

Indice : sous-requête dans `FROM` (table dérivée) + sous-requête scalaire pour la moyenne.

## Exercice 8 — Le(s) client(s) qui a(ont) le plus dépensé (max via sous-requête)

Sur les commandes `paid` uniquement, retournez le(s) client(s) qui a(ont) dépensé le plus au total :
- `email`
- `total_paid`

Indice : calculez `total_paid` par client, puis filtrez sur le `MAX(total_paid)`.
