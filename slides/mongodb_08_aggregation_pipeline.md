---
marp: true
title: "MongoDB — 03. Agrégation (1) : bases"
paginate: true
header: "[← Index MongoDB](https://antoine07.github.io/db_web2.2/mongodb_index.html)"
footer: "[← Index MongoDB](https://antoine07.github.io/db_web2.2/mongodb_index.html)"
---

# MongoDB — 03
## Agrégation (bases)

---

## Pourquoi l'agrégation ?

- "GROUP BY", calculs, transformations
- Reporting (counts, top cuisines, scores moyens…)

---

## `find` vs `aggregate`

- `find` : filtrer + projeter + trier (lecture "simple")
- `aggregate` : enchaîner des transformations (groupes, calculs, tableaux, reporting)

Règle : dès qu’on a besoin d’un "GROUP BY" ou de calculs sur des tableaux → `aggregate`.

---

## Structure d'un pipeline

```js
use("ny_restaurants");

db.restaurants.aggregate([
  { $match: { borough: "Manhattan" } },
  { $group: { _id: "$cuisine", count: { $sum: 1 } } },
  { $sort: { count: -1 } },
  { $limit: 10 }
]);
```

---

## Lire un pipeline (méthode)

1) Commencer petit (`$match` + `$limit`)
2) Ajouter 1 étape à la fois
3) Projeter tôt pour réduire les champs (`$project`)

---

## Étapes courantes

- `$match` : filtre
- `$project` : sélectionner/calculer des champs
- `$unwind` : "déplier" un tableau
- `$group` : agrégation
- `$sort`, `$limit`

---

## `$match` (filtrer tôt)

```js
db.restaurants.aggregate([
  { $match: { borough: "Manhattan", cuisine: "Italian" } },
  { $project: { name: 1, borough: 1, cuisine: 1, _id: 0 } },
  { $limit: 10 }
]);
```

---

## `$project` (choisir / calculer des champs)

```js
db.restaurants.aggregate([
  { $match: { borough: "Queens" } },
  {
    $project: {
      _id: 0,
      name: 1,
      borough: 1,
      cuisine: 1,
      zipcode: "$address.zipcode"
    }
  },
  { $limit: 10 }
]);
```

---

## `$unwind` (déplier un tableau)

Avant : 1 restaurant avec `grades: [...]`  
Après : 1 restaurant = N documents (1 par inspection).

```js
db.restaurants.aggregate([
  { $match: { borough: "Manhattan" } },
  { $unwind: "$grades" },
  { $limit: 5 }
]);
```

---

## Pourquoi on "déplie" un tableau ?

Un pipeline travaille **document par document** :
- `$match` filtre des documents
- `$group` agrège des documents

Or `grades` est un **tableau** (plusieurs inspections dans un seul document).

`$unwind` transforme chaque élément du tableau en **un document** dans le pipeline.  
Cela permet de filtrer et d’agréger **au niveau d’une inspection** (et pas seulement au niveau du restaurant).

---

## Exemple (objectif) : compter les inspections qui valent `"C"`

On veut compter le nombre d’inspections ayant `grade = "C"` dans toute la collection.

```js
db.restaurants.aggregate([
  { $unwind: "$grades" },
  { $match: { "grades.grade": "C" } },
  { $group: { _id: null, cInspections: { $sum: 1 } } }
]);
```

---

## Ce que `$unwind` fait vraiment (multiplication des docs)

Avant (1 restaurant, plusieurs inspections) :

```js
{ name: "X", grades: [{ grade: "A" }, { grade: "C" }] }
```

Après `$unwind: "$grades"` (1 doc → 2 docs) :

```js
{ name: "X", grades: { grade: "A" } }
{ name: "X", grades: { grade: "C" } }
```

Raison technique : après `$unwind`, `grades.grade` devient une valeur simple (plus un tableau), donc `$match` et `$group` peuvent s’appliquer directement.

---

## Pipeline : cuisines avec pire score moyen (Manhattan)

Peu d’opérateurs, mais un reporting complet : filtrer → déplier → agréger → filtrer → trier.

```js
db.restaurants.aggregate([
  { $match: { borough: "Manhattan" } },
  { $unwind: "$grades" },
  { $group: { _id: "$cuisine", avgScore: { $avg: "$grades.score" }, inspections: { $sum: 1 } } },
  { $match: { inspections: { $gte: 200 } } },
  { $sort: { avgScore: -1 } },
  { $limit: 10 }
]);
```

---

## `$group` (compter / agréger)

```js
db.restaurants.aggregate([
  { $group: { _id: "$borough", count: { $sum: 1 } } },
  { $sort: { count: -1 } }
]);
```

---

## Exemple : nombre de restaurants par borough

```js
db.restaurants.aggregate([
  { $group: { _id: "$borough", count: { $sum: 1 } } },
  { $sort: { count: -1 } }
]);
```

---

## Exemple : score moyen par cuisine (un borough)

```js
db.restaurants.aggregate([
  { $match: { borough: "Manhattan" } },
  { $unwind: "$grades" },
  { $group: { _id: "$cuisine", avgScore: { $avg: "$grades.score" } } },
  { $sort: { avgScore: 1 } },
  { $limit: 10 }
]);
```

---

## `countDocuments` vs `$count`

```js
// simple
db.restaurants.countDocuments({ borough: "Manhattan" });

// pipeline
db.restaurants.aggregate([
  { $match: { borough: "Manhattan" } },
  { $count: "count" }
]);
```

---

## À retenir

- L'agrégation est puissante, mais peut coûter cher sans index
- Toujours commencer par `$match` (réduire le volume tôt)

---

## Exercices

- Exercices : `Exercices/mongodb_08_aggregation_pipeline.md`
