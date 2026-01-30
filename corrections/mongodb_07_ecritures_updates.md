# Corrections MongoDB — 07. Écritures : updates + upsert

Préparation :

```js
use("ny_restaurants");
```

## Exercice 1 — `insertOne`

```js
db.restaurants.insertOne({
  restaurant_id: "demo-001",
  name: "Demo Restaurant",
  borough: "Manhattan",
  cuisine: "French",
  address: { building: "1", street: "Demo Street", zipcode: "10001", coord: [-73.99, 40.75] },
  grades: []
});
```

## Exercice 2 — `$set` et `$inc`

```js
db.restaurants.updateOne(
  { restaurant_id: "demo-001" },
  { $set: { cuisine: "French (Modern)" } }
);

db.restaurants.updateOne(
  { restaurant_id: "demo-001" },
  { $inc: { visits: 1 } }
);
```

## Exercice 3 — Upsert

```js
db.restaurants.updateOne(
  { restaurant_id: "demo-002" },
  {
    $set: {
      name: "Demo 2",
      borough: "Brooklyn",
      cuisine: "Italian",
      address: { building: "10", street: "Demo Ave", zipcode: "11215", coord: [-73.99, 40.67] },
      grades: []
    }
  },
  { upsert: true }
);
```

## Exercice 4 — Delete

```js
db.restaurants.deleteOne({ restaurant_id: "demo-001" });
```
