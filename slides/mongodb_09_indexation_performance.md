---
marp: true
title: "MongoDB — 04. Agrégation (2) : pipes avancés"
paginate: true
header: "[← Index MongoDB](https://antoine07.github.io/db_web2.2/mongodb_index.html)"
footer: "[← Index MongoDB](https://antoine07.github.io/db_web2.2/mongodb_index.html)"
---

# MongoDB — 04
## Agrégation : pipes avancés

---

## "Pipes" = pipeline

Un pipeline `aggregate([...])` = une suite d'étapes :
- chaque étape **transforme** un flux de documents
- la sortie d'une étape devient l'entrée de la suivante

Objectif : filtrer tôt (`$match`), réduire tôt (`$project`), puis agréger (`$group`).

---

## Méthode de debug

```js
// 1) commencer petit
db.restaurants.aggregate([{ $match: { borough: "Manhattan" } }, { $limit: 5 }]);

// 2) ajouter une étape à la fois
db.restaurants.aggregate([
  { $match: { borough: "Manhattan" } },
  { $project: { name: 1, cuisine: 1, grades: 1 } },
  { $limit: 2 }
]);
```

---

## Exemple : top restaurants (min 3 inspections)

```js
db.restaurants.aggregate([
  { $match: { borough: "Manhattan" } },
  { $unwind: "$grades" },
  {
    $group: {
      _id: "$restaurant_id",
      name: { $first: "$name" },
      cuisine: { $first: "$cuisine" },
      borough: { $first: "$borough" },
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

## `$group` : accumulateurs (à connaître)

Dans `$group`, on utilise des *accumulateurs* :

- `{ $sum: 1 }` → compter
- `{ $avg: "$grades.score" }` → moyenne
- `{ $min: ... }`, `{ $max: ... }` → min/max
- `{ $first: ... }`, `{ $last: ... }` → prendre une valeur

---

## Attention à `$first` / `$last`

`$first` / `$last` dépendent de l'ordre **avant** le `$group`.

Si on veut la "dernière inspection", on doit trier avant :

```js
db.restaurants.aggregate([
  { $match: { borough: "Manhattan" } },
  { $unwind: "$grades" },
  { $sort: { "grades.date": -1 } },
  {
    $group: {
      _id: "$restaurant_id",
      name: { $first: "$name" },
      lastGrade: { $first: "$grades.grade" },
      lastScore: { $first: "$grades.score" }
    }
  },
  { $limit: 5 }
]);
```

---

## Alternative : compter sans `$unwind`

Si on veut juste le nombre d'inspections (taille du tableau) :

```js
db.restaurants.aggregate([
  { $match: { borough: "Manhattan" } },
  { $project: { name: 1, gradesCount: { $size: "$grades" } } },
  { $sort: { gradesCount: -1 } },
  { $limit: 5 }
]);
```

---

## Exemple : distribution des scores (`$bucket`)

```js
db.restaurants.aggregate([
  // Transforme le tableau "grades" en un document par inspection
  // Chaque restaurant est dupliqué autant de fois qu’il a d’inspections
  { $unwind: "$grades" },

  {
    $bucket: {
      // Champ utilisé pour répartir les documents dans les intervalles
      groupBy: "$grades.score",

      // Bornes des intervalles (inclus à gauche, exclus à droite)
      // 0–9, 10–19, 20–29, 30–39, 40–49, 50–99
      boundaries: [0, 10, 20, 30, 40, 50, 100],

      // Bucket par défaut pour les scores >= 100 ou hors bornes
      default: "100+",

      // Pour chaque intervalle, on compte le nombre d’inspections
      output: {
        count: { $sum: 1 }
      }
    }
  }
]);
```

---

## À retenir

- Les "pipes" = **enchaînement d'étapes** (on compose des transformations)
- Debug : commencer avec `$match` + `$limit`, ajouter une étape à la fois
- Perf : `$match` tôt, `$project` tôt, éviter de "gonfler" les documents

---

## Exercices

- Exercices : `Exercices/mongodb_09_aggregation_pipes_avances.md`
