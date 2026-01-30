# Corrections MongoDB — 05. Requêtes de base

Préparation :

```js
use("ny_restaurants");
```

## Exercice 1 — Filtres simples

```js
db.restaurants.find({ borough: "Manhattan" }).limit(10);
db.restaurants.find({ borough: "Manhattan", cuisine: "Italian" }).limit(10);
db.restaurants.find({ "address.zipcode": "11215" }).limit(10);
```

## Exercice 2 — `IN` / `regex`

```js
db.restaurants.find({ borough: { $in: ["Bronx", "Queens"] } }).limit(10);
db.restaurants.find({ name: /pizza/i }, { name: 1, borough: 1, cuisine: 1, _id: 0 }).limit(10);
```

## Exercice 3 — Tri + pagination

```js
db.restaurants.find({ borough: "Queens" }, { name: 1, borough: 1, cuisine: 1, _id: 0 })
  .sort({ name: 1 })
  .limit(10);

db.restaurants.find({ borough: "Queens" }, { name: 1, borough: 1, cuisine: 1, _id: 0 })
  .sort({ name: 1 })
  .skip(10)
  .limit(10);
```

## Exercice 4 — Projections

```js
db.restaurants.find(
  {},
  { name: 1, borough: 1, cuisine: 1, "address.street": 1, "address.zipcode": 1, _id: 0 }
).limit(20);
```
