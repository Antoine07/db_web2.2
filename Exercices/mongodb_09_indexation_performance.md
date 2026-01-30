# Exercices MongoDB — 09. Indexation & performance

Préparation :

```js
use("ny_restaurants");
```

## Exercice 1 — Index unique

Créez (ou vérifiez) un index unique sur `restaurants.restaurant_id`.

## Exercice 2 — Explain

Sur la requête :

```js
db.restaurants.find({ borough: "Manhattan", cuisine: "Italian" }).sort({ name: 1 });
```

1) Lancez `explain("executionStats")`  
2) Vérifiez si un index est utilisé

## Exercice 3 — Index composé (bonus)

Ajoutez l’index le plus logique si nécessaire, puis relancez `explain`.

## Exercice 4 — Index sur champ imbriqué (bonus)

Créez un index sur `address.zipcode` puis testez une requête filtrant par zipcode.
