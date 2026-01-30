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

- `find` : filtrer + projeter + trier (lecture “simple”)
- `aggregate` : enchaîner des transformations (groupes, calculs, tableaux, reporting)

Règle : dès que tu as besoin d’un “GROUP BY” ou de calculs sur des tableaux → `aggregate`.

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

## `$unwind` — Exemple concret (avant / après)

Avant (`grades` est un tableau) :

```js
{
  name: "Morris Park Bake Shop",
  grades: [{ score: 2 }, { score: 6 }]
}
```

Après `$unwind: "$grades"` (1 doc → 2 docs) :

```js
{ name: "Morris Park Bake Shop", grades: { score: 2 } }
{ name: "Morris Park Bake Shop", grades: { score: 6 } }
```

---

## `$unwind` — Quand l’utiliser ?

Tu l’utilises surtout quand tu veux travailler **au niveau des éléments du tableau** :

- filtrer / trier **sur chaque** inspection (`grades.score`, `grades.grade`, `grades.date`)
- calculer des stats basées sur les inspections (moyenne, min, max…)
- faire des “lignes” à partir d’un tableau (reporting)

Si tu veux juste savoir “est-ce qu’il existe au moins un élément qui match ?”, tu peux parfois éviter `$unwind` avec un `find` (ou un `$match`) sur un champ du tableau.

---

## `$unwind` — Syntaxe simple vs options

Syntaxe simple :

```js
{ $unwind: "$grades" }
```

Syntaxe avec options :

```js
{
  $unwind: {
    path: "$grades",
    includeArrayIndex: "gradeIndex",
    preserveNullAndEmptyArrays: true
  }
}
```

---

## Options de `$unwind` (ce que ça change)

- `path` : le champ tableau à “déplier”
- `includeArrayIndex` : ajoute l’index de l’élément déplié (0, 1, 2…)
- `preserveNullAndEmptyArrays` :
  - `false` (par défaut) : si le tableau est vide / manquant → le doc disparaît
  - `true` : le doc est conservé (avec `grades: null`)

---

## Filtrer “un restaurant” vs “une inspection”

**Cas 1 — garder les restaurants qui ont AU MOINS une inspection avec score ≥ 30** :

```js
db.restaurants.aggregate([{ $match: { "grades.score": { $gte: 30 } } }]);
```

**Cas 2 — obtenir les inspections (1 doc = 1 inspection) avec score ≥ 30** :

```js
db.restaurants.aggregate([
  { $unwind: "$grades" },
  { $match: { "grades.score": { $gte: 30 } } }
]);
```

---

## Piège : `$unwind` “multiplie” les documents

Si tu as :
- 1 000 restaurants
- ~10 inspections chacun

Après `$unwind: "$grades"` → ~10 000 documents dans le pipeline.

Bon réflexe :
- `$match` le plus tôt possible (avant `$unwind`)
- `$project` les champs utiles seulement
- `$limit` pendant que tu développes ton pipeline

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
