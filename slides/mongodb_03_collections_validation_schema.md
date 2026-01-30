---
marp: true
title: "MongoDB — 06. Validation : JSON Schema"
paginate: true
header: "[← Index MongoDB](https://antoine07.github.io/db_web2.2/mongodb_index.html)"
footer: "[← Index MongoDB](https://antoine07.github.io/db_web2.2/mongodb_index.html)"
---

# MongoDB — 06
## Validation de schéma (JSON Schema)

---

## Pourquoi valider ?

- Éviter les documents incohérents (types/champs manquants)
- Documenter le modèle "attendu"
- Sécuriser les insert/update quand plusieurs apps écrivent

---

## Exemple simple : créer une collection avec validation

```js
use("ny_restaurants");

db.demo_restaurants.drop();
db.createCollection("demo_restaurants", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["name"],
      properties: {
        name: { bsonType: "string" },
        borough: { bsonType: "string" }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

db.demo_restaurants.insertOne({ name: "OK", borough: "Manhattan" });
// db.demo_restaurants.insertOne({ name: 123 }); // => erreur de validation
```

---

## Appliquer une validation sur `restaurants` (collMod)

```js
db.runCommand({
  collMod: "restaurants",
  validationLevel: "moderate",
  validationAction: "error",
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["restaurant_id", "name", "borough", "cuisine", "address"],
      properties: {
        restaurant_id: { bsonType: "string" },
        name: { bsonType: "string" },
        borough: { bsonType: "string" },
        cuisine: { bsonType: "string" },
        address: {
          bsonType: "object",
          required: ["zipcode"],
          properties: {
            building: { bsonType: "string" },
            street: { bsonType: "string" },
            zipcode: { bsonType: "string" }
          }
        }
      }
    }
  }
});
```

---

## `validationLevel` / `validationAction`

- `validationLevel` :
  - `strict` : vérifie aussi les inserts/updates sur docs existants
  - `moderate` : vérifie surtout les nouveaux docs et les champs modifiés
  - `off` : désactive la validation
- `validationAction` :
  - `error` : reject (erreur)
  - `warn` : log côté serveur (utile en transition)

---

## Tester la validation (exemple rapide)

```js
use("ny_restaurants");

db.demo_restaurants.drop();
db.createCollection("demo_restaurants", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["name"],
      properties: { name: { bsonType: "string" } }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

db.demo_restaurants.insertOne({ name: "OK" });
// db.demo_restaurants.insertOne({ name: 123 }); // => erreur
```

---

## Stratégie "progressive"

- Au début : valider "minimalement" (champs + types les plus critiques)
- En prod : parfois `validationAction: "warn"` le temps de nettoyer les données
- Puis renforcer petit à petit

---

## À retenir

- MongoDB = flexible, mais la validation aide à garder un modèle propre
- La validation MongoDB complète la validation "côté code" (on fait les deux)

---

## Exercices

- Exercices : `Exercices/mongodb_03_collections_validation_schema.md`
