---
marp: true
title: "MongoDB — 07. Écritures : insert/update, opérateurs, upsert"
paginate: true
header: "[← Index MongoDB](https://antoine07.github.io/db_web2.2/mongodb_index.html)"
footer: "[← Index MongoDB](https://antoine07.github.io/db_web2.2/mongodb_index.html)"
---

# MongoDB — 07
## Écritures : `insert`, `update`, opérateurs, upsert

---

## Insérer

```js
use("ny_restaurants");

db.restaurants.insertOne({
  restaurant_id: "demo-001",
  name: "Demo Restaurant",
  borough: "Manhattan",
  cuisine: "French",
  address: {
    building: "1",
    street: "Demo Street",
    zipcode: "10001",
    coord: [-73.99, 40.75]
  },
  grades: []
});
```

---

## Mettre à jour (important : opérateurs)

```js
db.restaurants.updateOne(
  { restaurant_id: "demo-001" },
  { $set: { cuisine: "French (Modern)" } }
);
```

---

## Opérateurs utiles

- `$set`, `$unset`
- `$inc` (compteurs)
- `$push`, `$pull` (tableaux)
- `$addToSet` (éviter doublons)

---

## Upsert

"Met à jour sinon crée"

```js
db.restaurants.updateOne(
  { restaurant_id: "demo-002" },
  {
    $set: {
      name: "Demo 2",
      borough: "Brooklyn",
      cuisine: "Italian",
      address: {
        building: "10",
        street: "Demo Ave",
        zipcode: "11215",
        coord: [-73.99, 40.67]
      },
      grades: []
    }
  },
  { upsert: true }
);
```

---

## Delete

```js
db.restaurants.deleteOne({ restaurant_id: "demo-001" });
```

---

## À retenir

- Sans opérateur (`$set`, …), `updateOne` remplace le document entier
- Upsert = pratique, mais à utiliser avec un filtre "stable" (ex: `sku`)

---

## Exercices

- Exercices : `Exercices/mongodb_07_ecritures_updates.md`
