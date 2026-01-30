# Corrections MongoDB — Agrégation (1) : bases

Préparation :

```js
use("ny_restaurants");
```

## Exercice 1 — Compter par borough

```js
db.restaurants.aggregate([
  { $group: { _id: "$borough", count: { $sum: 1 } } },
  { $sort: { count: -1 } }
]);
```

## Exercice 2 — Top cuisines (Manhattan)

```js
db.restaurants.aggregate([
  { $match: { borough: "Manhattan" } },
  { $group: { _id: "$cuisine", count: { $sum: 1 } } },
  { $sort: { count: -1 } },
  { $limit: 10 }
]);
```

## Exercice 3 — Score moyen par cuisine (bonus)

```js
db.restaurants.aggregate([
  { $match: { borough: "Manhattan" } },
  { $unwind: "$grades" },
  { $group: { _id: "$cuisine", avgScore: { $avg: "$grades.score" } } },
  { $sort: { avgScore: 1 } },
  { $limit: 10 }
]);
```
