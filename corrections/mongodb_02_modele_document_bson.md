# Corrections MongoDB — 02. Requêtes `find`

Préparation :

```js
use("ny_restaurants");
```

## Exercice 1 — Projection

```js
db.restaurants.find({}, { name: 1, borough: 1, cuisine: 1, _id: 0 }).limit(20);
```

## Exercice 2 — Filtres simples (AND)

```js
db.restaurants.find(
  { borough: "Manhattan", cuisine: "Italian" },
  { name: 1, "address.zipcode": 1, _id: 0 }
).limit(10);
```

## Exercice 3 — `IN` (`$in`)

```js
db.restaurants.find(
  { borough: { $in: ["Bronx", "Queens", "Brooklyn"] } },
  { name: 1, borough: 1, cuisine: 1, _id: 0 }
).limit(20);

db.restaurants.countDocuments({ borough: { $in: ["Bronx", "Queens", "Brooklyn"] } });
```

## Exercice 4 — Regex (recherche “contient”)

```js
db.restaurants.find(
  { name: /pizza/i },
  { name: 1, borough: 1, cuisine: 1, _id: 0 }
).limit(10);
```

## Exercice 5 — Champs imbriqués (dot notation)

```js
db.restaurants.find(
  { "address.zipcode": "11215" },
  { name: 1, "address.street": 1, "address.zipcode": 1, _id: 0 }
).limit(20);
```

## Exercice 6 — Tri + pagination

```js
db.restaurants.find({ borough: "Queens" }, { name: 1, borough: 1, cuisine: 1, _id: 0 })
  .sort({ name: 1 })
  .skip(10)
  .limit(10);
```

## Exercice 7 — Tableaux (match sur un champ)

```js
db.restaurants.find(
  { "grades.grade": "C" },
  { name: 1, borough: 1, cuisine: 1, _id: 0 }
).limit(10);
```

## Exercice 8 — Tableaux : `$elemMatch` (même élément)

```js
db.restaurants.find(
  { grades: { $elemMatch: { grade: "A", score: { $lt: 5 } } } },
  { name: 1, borough: 1, cuisine: 1, _id: 0 }
).limit(10);
```
