# Exercices MongoDB — 05. Requêtes de base

Préparation :

```js
use("ny_restaurants");
```

## Exercice 1 — Filtres simples

1) Restaurants à `borough = "Manhattan"`  
2) Restaurants avec `cuisine = "Italian"` dans Manhattan  
3) Restaurants dont `address.zipcode` est `11215`

## Exercice 2 — `IN` / `regex`

1) Restaurants dont `borough` est dans `["Bronx", "Queens"]`  
2) Restaurants dont `name` contient `pizza` (via regex, insensible à la casse)

## Exercice 3 — Tri + pagination

1) 10 restaurants de Queens, triés par `name` (sans `_id`)  
2) Pagination : reprenez la requête précédente avec `skip(10)` puis `limit(10)`

## Exercice 4 — Projections

Sur `restaurants`, affichez uniquement :
- `name`
- `borough`
- `cuisine`
- `address.street` + `address.zipcode`
