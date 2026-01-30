# Corrections — 04. Fil rouge : Boutique (schéma)

## Exercice 1 — Explorer le schéma

Énoncé :
1) Afficher la liste des tables (`\dt`)  
2) Regarder la structure de chaque table (`\d ...`)  
Puis répondre :
- rôle de chaque table (1 phrase)
- colonnes “identifiants”
- colonnes qui relient des tables entre elles

```sql
\dt

\d customers
\d orders
\d order_items
\d products
\d categories
```

Rôles (exemples) :
- `customers` : référentiel des clients
- `orders` : événements "commande" (date, statut, client) historique des commandes
- `order_items` : lignes de commande (produit, quantité, prix au moment T)
- `products` : catalogue
- `categories` : référentiel de catégories

Colonnes "identifiants" (exemples) :
- `customers.id`, `orders.id`, `products.id`, `categories.id`
- `order_items.order_id` + `order_items.product_id` (identifie une ligne de commande)

Colonnes qui "relient" (exemples) :
- `orders.customer_id`
- `products.category_id`
- `order_items.order_id`
- `order_items.product_id`

## Exercice 2 — Prix catalogue vs prix au moment

Énoncé :
1) Où se trouve le prix "catalogue" ?  
2) Où se trouve le prix "au moment de la commande" ?  
3) Pourquoi garder les deux ?

- Prix catalogue : `products.price`
- Prix "au moment de la commande" : `order_items.unit_price` (peut être remisé par rapport au prix catalogue)
- On garde les deux : le catalogue peut changer mais on doit pouvoir recalculer l'historique des commandes.

## Exercice 3 — Explorer une commande

Énoncé :
1) Choisir un `order_id` existant  
2) Lister ses lignes dans `order_items`  
3) Vérifier le total (à la main puis avec un `SUM`)

```sql
SELECT id FROM orders LIMIT 1;
SELECT * FROM order_items WHERE order_id = 1;
SELECT SUM(quantity * unit_price) AS total FROM order_items WHERE order_id = 1;
```

## Exercice 4 — Index

Énoncé : lister les index de `orders`, puis répondre :
- Quels champs sont indexés ?
- À quelles requêtes ça peut servir ?

```sql
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'orders'
ORDER BY indexname;
```

Exemples d'usage :
- index sur `customer_id` : commandes d'un client
- index sur `status` : commandes payées / en attente
- index sur `ordered_at` : tri/filtre par date
