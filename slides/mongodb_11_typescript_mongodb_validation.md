---
marp: true
title: "MongoDB — 07. TypeScript + MongoDB : typage d'abord (avant la DB)"
paginate: true
header: "[← Index MongoDB](https://antoine07.github.io/db_web2.2/mongodb_index.html)"
footer: "[← Index MongoDB](https://antoine07.github.io/db_web2.2/mongodb_index.html)"
---

# MongoDB — 07
## TypeScript : l'importance du typage "en amont"

---

## Idée clé

- Les types TS évitent des erreurs **avant** d'écrire en DB (autocomplétion + refactor safe)
- Mais : un type TS n'existe plus à l'exécution → MongoDB peut renvoyer des données invalides
- Donc : type TS + (souvent) validation runtime, puis DB validation si besoin

---

## Dépendances (exemple)

```bash
npm i mongodb zod
npm i -D typescript tsx @types/node
```

Exemple complet : `examples/mongodb-ts-validation/`

---

## Étape 1 — Un type `Restaurant` (compile-time)

```ts
export type Restaurant = {
  restaurant_id: string;
  name: string;
  borough: string;
  cuisine: string;
  address: { zipcode: string; street?: string };
};
```

---

## Typage "en amont" : `satisfies`

Ça protège quand on **construit** l'objet dans le code.

```ts
const candidate = {
  restaurant_id: "demo-ts-001",
  name: "Demo TS",
  borough: "Manhattan",
  cuisine: "French",
  address: { zipcode: "10001" }
} satisfies Restaurant;
```

---

## Limite : un cast ne valide rien

❌ Anti-pattern :

```ts
const raw = await collection.findOne({ restaurant_id: "50003079" });
const restaurant = raw as Restaurant;
```

Si `raw` est `null` / incomplet / mauvais type → bug runtime.

---

## Étape 2 — Typage + validation runtime (Zod)

```ts
import { z } from "zod";

export const RestaurantSchema = z.object({
  restaurant_id: z.string(),
  name: z.string(),
  borough: z.string(),
  cuisine: z.string(),
  address: z.object({
    street: z.string().optional(),
    zipcode: z.string()
  })
});

export type Restaurant = z.infer<typeof RestaurantSchema>;
```

---

## Lecture : valider ce qui vient de l'extérieur

```ts
const raw = await collection.findOne({ restaurant_id: "50003079" });
const restaurant = RestaurantSchema.parse(raw);
```

---

## Écriture : valider si la source est "non fiable"

```ts
// formulaire / API / CSV / etc.
const safe = RestaurantSchema.parse(candidate);
await collection.insertOne(safe);
```

---

## Et la validation côté MongoDB ?

On peut la rendre "optionnelle" si :
- on contrôle l'unique app qui écrit
- et on valide déjà runtime côté TS

Sinon (multi writers) → garde-fou DB recommandé :

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
        address: { bsonType: "object", required: ["zipcode"], properties: { zipcode: { bsonType: "string" } } }
      }
    }
  }
});
```

---

## À retenir

- Typage TS = empêche beaucoup d'erreurs *avant* la DB
- Validation runtime = indispensable pour les entrées/lectures externes
- Validation MongoDB = garde-fou "DB-level" quand il y a plusieurs writers
