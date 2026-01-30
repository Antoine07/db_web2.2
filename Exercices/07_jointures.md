# Exercices — 07. Jointures

## Préparation

```sql
-- Dans psql :
\c shop
```

## Exercice 1 — Commandes avec email client

Retournez la liste des commandes :
- `order_id`, `ordered_at`, `status`
- `customer_email`

## Exercice 2 — Détail d’une commande

Pour la commande `order_id = 4`, affichez :
- le nom des produits
- la quantité
- le prix unitaire de la ligne (`unit_price`)

## Exercice 3 — Clients sans commande

Affichez tous les clients (email) + le nombre de commandes associées, en gardant :
- les clients sans commande

Indice : `LEFT JOIN` + agrégation (vous l’améliorerez au chapitre 08).

## Exercice 4 — Produits et catégories

Listez les produits avec :
- `product_name`, `price`
- `category_name`

## Exercice 5 — Commandes “payées” uniquement (piège)

Objectif :
- afficher tous les clients
- et, si elles existent, leurs commandes **payées**

1) Essayez avec `LEFT JOIN` + filtre dans `WHERE`  
2) Comparez avec `LEFT JOIN` + filtre dans le `ON`  
3) Expliquez la différence de résultat

## Exercice 6 — Trouver les commandes “vides”

Retournez les commandes qui n’ont **aucune** ligne dans `order_items`.

Indice : `LEFT JOIN ... WHERE oi.order_id IS NULL`.

## Exercice 7 — Toutes les commandes d’un client

Pour un client donné (`customer_id = 1`), retournez toutes ses commandes avec le détail des produits :
- `order_id`, `ordered_at`, `status`
- `product_name`, `quantity`, `unit_price`
- total de ligne : `quantity * unit_price` (alias `line_total`)

Triez par date de commande décroissante, puis `order_id`.
