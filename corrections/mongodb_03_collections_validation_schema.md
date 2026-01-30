# Corrections MongoDB — 03. Collections & validation de schéma

Préparation :

```js
use("ny_restaurants");
```

## Exercice 1 — Comprendre les types

```js
db.restaurants.findOne();
```

- `_id` : `ObjectId`
- `grades.date` : `Date` (`ISODate`)

## Exercice 2 — Validation (concept)

Exemple :
- requis : `restaurant_id`, `name`, `borough`, `cuisine`, `address.zipcode`, `address.coord`
- types : strings pour ids/noms, `coord` = array[2] de numbers, `grades.score` number, `grades.date` date

## Exercice 3 — Appliquer une validation (optionnel)

```js
db.runCommand({
  collMod: "restaurants",
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["name", "restaurant_id", "borough", "cuisine", "address"],
      properties: {
        name: { bsonType: "string" },
        restaurant_id: { bsonType: "string" },
        borough: { bsonType: "string" },
        cuisine: { bsonType: "string" },
        address: {
          bsonType: "object",
          required: ["zipcode", "coord"],
          properties: {
            building: { bsonType: "string" },
            street: { bsonType: "string" },
            zipcode: { bsonType: "string" },
            coord: {
              bsonType: "array",
              minItems: 2,
              maxItems: 2,
              items: { bsonType: ["double", "int", "long", "decimal"] }
            }
          }
        }
      }
    }
  }
});
```
