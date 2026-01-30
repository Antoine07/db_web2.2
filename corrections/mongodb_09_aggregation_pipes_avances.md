# Corrections MongoDB — Agrégation (2) : pipes avancés

Préparation :

```js
use("ny_restaurants");
```

## Exercice 1 — Top restaurants (min 3 inspections)

```js
db.restaurants.aggregate([
  { $match: { borough: "Manhattan" } },
  { $unwind: "$grades" },
  {
    $group: {
      _id: "$restaurant_id",
      name: { $first: "$name" },
      cuisine: { $first: "$cuisine" },
      gradesCount: { $sum: 1 },
      avgScore: { $avg: "$grades.score" }
    }
  },
  { $match: { gradesCount: { $gte: 3 } } },
  { $sort: { avgScore: 1 } },
  { $limit: 10 }
]);
```

## Exercice 2 — Distribution des scores (`$bucket`)

```js
db.restaurants.aggregate([
  { $unwind: "$grades" },
  {
    $bucket: {
      groupBy: "$grades.score",
      boundaries: [0, 10, 20, 30, 40, 50, 100],
      default: "100+",
      output: { count: { $sum: 1 } }
    }
  }
]);
```

## Exercice 3 — 2 rapports en 1 (`$facet`)

```js
db.restaurants.aggregate([
  {
    $facet: {
      byBorough: [
        { $group: { _id: "$borough", count: { $sum: 1 } } },
        { $sort: { count: -1 } }
      ],
      topCuisinesInManhattan: [
        { $match: { borough: "Manhattan" } },
        { $group: { _id: "$cuisine", count: { $sum: 1 } } },
        { $sort: { count: -1 } },
        { $limit: 10 }
      ]
    }
  }
]);
```

## Exercice 4 — Debug de pipeline (bonus)

Exemple de version “debug” (on limite tôt, on projette tôt) :

```js
db.restaurants.aggregate([
  { $match: { borough: "Manhattan" } },
  { $project: { restaurant_id: 1, name: 1, cuisine: 1, grades: 1 } },
  { $limit: 200 },
  { $unwind: "$grades" },
  {
    $group: {
      _id: "$restaurant_id",
      name: { $first: "$name" },
      cuisine: { $first: "$cuisine" },
      gradesCount: { $sum: 1 },
      avgScore: { $avg: "$grades.score" }
    }
  },
  { $match: { gradesCount: { $gte: 3 } } },
  { $sort: { avgScore: 1 } },
  { $limit: 10 }
]);
```

