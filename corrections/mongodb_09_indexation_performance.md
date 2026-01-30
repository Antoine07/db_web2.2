# Corrections MongoDB — 09. Indexation & performance

Préparation :

```js
use("ny_restaurants");
```

## Exercice 1 — Index unique

```js
db.restaurants.createIndex({ restaurant_id: 1 }, { unique: true });
db.restaurants.getIndexes();
```

On doit voir un index sur `restaurant_id` avec `unique: true`.

## Exercice 2 — Explain

```js
db.restaurants.find({ borough: "Manhattan", cuisine: "Italian" })
  .sort({ name: 1 })
  .explain("executionStats");
```

## Exercice 3 — Index composé (bonus)

Créer un index cohérent avec filtre + tri :

```js
db.restaurants.createIndex({ borough: 1, cuisine: 1, name: 1 });
```

Puis relancer `explain` et vérifier qu’un index est utilisé (ex: `IXSCAN`).

## Exercice 4 — Index sur champ imbriqué (bonus)

```js
db.restaurants.createIndex({ "address.zipcode": 1 });
db.restaurants.find({ "address.zipcode": "11215" }).explain("executionStats");
```
