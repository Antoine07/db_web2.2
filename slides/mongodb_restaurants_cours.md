---
marp: true
title: "MongoDB — Dataset restaurants"
paginate: true
header: "[← Index MongoDB](https://antoine07.github.io/db_web2.2/mongodb_index.html)"
footer: "[← Index MongoDB](https://antoine07.github.io/db_web2.2/mongodb_index.html)"
---

# MongoDB — Dataset `restaurants`
## `find` → `aggregate` → `update/delete` → aggregate (avancé)

---

## Setup (Docker du repo)

Depuis `starter/` :

```bash
docker compose up -d

# récupérer les données (si besoin)
curl -L "https://raw.githubusercontent.com/mongodb/docs-assets/primer-dataset/primer-dataset.json" \
  -o shared/mongodb/restaurants.json

# import: base `ny_restaurants`, collection `restaurants`
docker compose exec -T mongodb mongoimport \
  --db ny_restaurants \
  --collection restaurants \
  --authenticationDatabase admin \
  --username root \
  --password root \
  --drop \
  --file /shared/restaurants.json
```

Connexion :

```bash
docker compose exec mongodb mongosh "mongodb://root:root@localhost:27017/ny_restaurants?authSource=admin"
```

---

## Le dataset (structure)

Dans `mongosh` :

```js
db.restaurants.findOne();
```

Champs typiques :
- `name`, `borough`, `cuisine`, `restaurant_id`
- `address`: `building`, `street`, `zipcode`, `coord` (lon/lat)
- `grades[]`: `{ date, grade, score }`

---

# 1) `find`
## Lire des documents (filtres, projection, tri)

---

## `find()` + `limit()`

```js
db.restaurants.find().limit(3);
```

---

## Filtrer (équivalent d’un `WHERE`)

```js
db.restaurants.find(
  { borough: "Manhattan", cuisine: "Italian" },
  { name: 1, borough: 1, cuisine: 1, "address.zipcode": 1, _id: 0 }
).limit(10);
```

---

## Projection (choisir les champs)

```js
db.restaurants.find(
  { borough: "Brooklyn" },
  { name: 1, "address.street": 1, "address.zipcode": 1, _id: 0 }
).limit(10);
```

---

## Tri + pagination

```js
db.restaurants.find(
  { borough: "Queens" },
  { name: 1, cuisine: 1, _id: 0 }
)
  .sort({ name: 1 })
  .skip(20)
  .limit(10);
```

---

## Recherche “contient” (regex)

```js
db.restaurants.find(
  { name: /pizza/i },
  { name: 1, borough: 1, cuisine: 1, _id: 0 }
).limit(10);
```

---

## Champs imbriqués (dot notation)

```js
db.restaurants.find(
  { "address.zipcode": "11215" },
  { name: 1, "address.street": 1, "address.zipcode": 1, _id: 0 }
).limit(10);
```

---

## Tableaux : match “au moins un élément”

Tous les restaurants qui ont déjà eu une note `C` :

```js
db.restaurants.find(
  { "grades.grade": "C" },
  { name: 1, borough: 1, cuisine: 1, grades: 1, _id: 0 }
).limit(5);
```

---

## Tableaux : `$elemMatch` (même élément)

Au moins une inspection avec `grade=A` **et** `score < 5` :

```js
db.restaurants.find(
  { grades: { $elemMatch: { grade: "A", score: { $lt: 5 } } } },
  { name: 1, borough: 1, cuisine: 1, grades: 1, _id: 0 }
).limit(5);
```

---

# 2) `aggregate` (intro)
## Compter / regrouper / calculer

---

## Compter par borough

```js
db.restaurants.aggregate([
  { $group: { _id: "$borough", count: { $sum: 1 } } },
  { $sort: { count: -1 } }
]);
```

---

## Top cuisines (par borough)

```js
db.restaurants.aggregate([
  { $match: { borough: "Bronx" } },
  { $group: { _id: "$cuisine", count: { $sum: 1 } } },
  { $sort: { count: -1 } },
  { $limit: 10 }
]);
```

---

## Nombre moyen d’inspections par restaurant

```js
db.restaurants.aggregate([
  { $project: { gradesCount: { $size: "$grades" } } },
  { $group: { _id: null, avgGrades: { $avg: "$gradesCount" } } }
]);
```

---

# 3) `update` + `delete` (à la fin)
## Modifier et supprimer des documents

---

## Créer un document “démo”

```js
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

## `updateOne` (toujours avec opérateurs)

```js
db.restaurants.updateOne(
  { restaurant_id: "demo-001" },
  { $set: { cuisine: "French (Modern)" } }
);
```

---

## Mettre à jour un tableau (`$push`, `$addToSet`)

```js
db.restaurants.updateOne(
  { restaurant_id: "demo-001" },
  {
    $push: {
      grades: { date: ISODate("2026-01-01T00:00:00Z"), grade: "A", score: 10 }
    },
    $addToSet: { tags: "demo" }
  }
);
```

---

## `deleteOne`

```js
db.restaurants.deleteOne({ restaurant_id: "demo-001" });
```

---

## À retenir

- Sans opérateur (`$set`, `$inc`, …), un `updateOne` remplace le document entier
- Préférer des filtres stables (ex: `restaurant_id`)

---

# 4) `aggregate` (avancé)
## Comprendre les “pipes” (pipeline) + exemples utiles

---

## C’est quoi un “pipe” ici ?

`aggregate([...])` = une **suite d’étapes**.

Chaque étape :
- prend des documents en entrée
- renvoie des documents en sortie
- alimente l’étape suivante

Idée : comme un enchaînement de filtres/transformations.

---

## Pipeline typique

```js
db.restaurants.aggregate([
  { $match: { borough: "Manhattan" } }, // filtrer tôt
  { $project: { name: 1, cuisine: 1, grades: 1 } }, // garder utile
  { $unwind: "$grades" }, // “déplier” le tableau
  { $group: { _id: "$cuisine", avgScore: { $avg: "$grades.score" } } },
  { $sort: { avgScore: 1 } }, // score bas = mieux (inspections NYC)
  { $limit: 10 }
]);
```

---

## Focus : `$unwind` (le “dépliage”)

`grades` est un tableau d’inspections :

- avant : 1 restaurant = 1 document avec `grades: [...]`
- après `$unwind: "$grades"` : 1 restaurant = **N documents** (1 par inspection)

Très utile pour :
- filtrer / trier **par inspection** (`grades.score`, `grades.grade`, `grades.date`)
- faire des stats sur les inspections (moyenne, min, max…)

Attention : `$unwind` peut multiplier fortement le nombre de documents → filtrer tôt (`$match`) et garder peu de champs (`$project`).

---

## Top restaurants (score moyen, min 3 inspections)

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

---

## Distribution des scores (bucket)

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

---

## Faire 2 rapports en 1 requête (`$facet`)

```js
db.restaurants.aggregate([
  {
    $facet: {
      byBorough: [
        { $group: { _id: "$borough", count: { $sum: 1 } } },
        { $sort: { count: -1 } }
      ],
      topCuisines: [
        { $group: { _id: "$cuisine", count: { $sum: 1 } } },
        { $sort: { count: -1 } },
        { $limit: 10 }
      ]
    }
  }
]);
```

---

## Conclusion

- `find` = lecture + filtres + projection + tri
- `aggregate` = calculs/reporting (très puissant)
- `update/delete` = toujours avec des filtres précis + opérateurs
