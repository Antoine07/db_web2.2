# Corrections MongoDB — 06. Relations & `$lookup`

Préparation :

```js
use("ny_restaurants");
```

## Exercice 1 — Créer une collection “référencée”

```js
db.boroughs.deleteMany({});
db.boroughs.insertMany([
  { _id: "Manhattan", area: "NYC", note: "Île + downtown/midtown/uptown" },
  { _id: "Brooklyn", area: "NYC", note: "Sud/Est de Manhattan" },
  { _id: "Queens", area: "NYC", note: "A l'est" },
  { _id: "Bronx", area: "NYC", note: "Au nord" },
  { _id: "Staten Island", area: "NYC", note: "Sud-ouest" }
]);
```

## Exercice 2 — Joindre `restaurants` → `boroughs`

```js
db.restaurants.aggregate([
  { $match: { borough: "Manhattan" } },
  {
    $lookup: {
      from: "boroughs",
      localField: "borough",
      foreignField: "_id",
      as: "borough_info"
    }
  },
  { $unwind: "$borough_info" },
  {
    $project: {
      _id: 0,
      name: 1,
      cuisine: 1,
      borough: 1,
      borough_note: "$borough_info.note"
    }
  },
  { $limit: 5 }
]);
```

## Exercice 3 — Joindre par cuisine (bonus)

```js
db.cuisines.deleteMany({});
db.cuisines.insertMany([
  { _id: "Italian", origin: "Italy", tags: ["pasta", "pizza"] },
  { _id: "American", origin: "USA", tags: ["diner", "burger"] },
  { _id: "Chinese", origin: "China", tags: ["noodles"] }
]);

db.restaurants.aggregate([
  { $match: { borough: "Manhattan" } },
  {
    $lookup: {
      from: "cuisines",
      localField: "cuisine",
      foreignField: "_id",
      as: "cuisine_info"
    }
  },
  { $unwind: { path: "$cuisine_info", preserveNullAndEmptyArrays: true } },
  { $project: { _id: 0, name: 1, borough: 1, cuisine: 1, cuisine_info: 1 } },
  { $limit: 5 }
]);
```
