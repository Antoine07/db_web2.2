---
marp: true
title: "MongoDB — 02. Requêtes de base : find"
paginate: true
header: "[← Index MongoDB](https://antoine07.github.io/db_web2.2/mongodb_index.html)"
footer: "[← Index MongoDB](https://antoine07.github.io/db_web2.2/mongodb_index.html)"
---

# MongoDB — 02
## `find` (filtres, projection, tri)

---

## Préparation

```js
use("ny_restaurants");
```

---

## `find(filter, projection)`

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
db.restaurants.find({ borough: "Queens" }, { name: 1, cuisine: 1, _id: 0 })
  .sort({ name: 1 })
  .skip(20)
  .limit(10);
```

---

## Opérateurs courants

- Comparaisons : `$eq`, `$ne`, `$gt`, `$gte`, `$lt`, `$lte`
- Ensembles : `$in`, `$nin`
- Texte : `$regex` (avec prudence)
- Existence : `$exists`

---

## Exemple : `$in` (équivalent "IN")

```js
db.restaurants.find(
  { borough: { $in: ["Bronx", "Queens", "Brooklyn"] } },
  { name: 1, borough: 1, cuisine: 1, _id: 0 }
).limit(10);
```

---

## Exemple : `$regex` (recherche "contient")

```js
db.restaurants.find(
  { name: /pizza/i },
  { name: 1, borough: 1, cuisine: 1, _id: 0 }
).limit(10);
```

---

## Exemple : comparaisons (`$gte`, `$lte`)

Ici : "au moins une inspection avec un score ≥ 30" :

```js
db.restaurants.find(
  { "grades.score": { $gte: 30 } },
  { name: 1, borough: 1, cuisine: 1, _id: 0 }
).limit(10);
```

---

## Exemple : `$exists` (champ présent / absent)

```js
db.restaurants.find(
  { "address.street": { $exists: true } },
  { name: 1, "address.street": 1, _id: 0 }
).limit(5);
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

## Tableaux : match "au moins un élément"

```js
// Tous les restaurants qui ont déjà eu une note C
db.restaurants.find(
  { "grades.grade": "C" },
  { name: 1, borough: 1, cuisine: 1, _id: 0 }
).limit(10);
```

---

## Tableaux : `$elemMatch` (même élément)

```js
// Au moins une inspection avec grade=A ET score < 5
db.restaurants.find(
  { grades: { $elemMatch: { grade: "A", score: { $lt: 5 } } } },
  { name: 1, borough: 1, cuisine: 1, _id: 0 }
).limit(10);
```

---

## Piège : sans `$elemMatch`, on peut avoir des faux positifs

Démo (collection `etudiants`) :

```js
db.etudiants.insertMany([
  {
    nom: "Alice",
    notes: [
      { matiere: "maths", note: 18 },
      { matiere: "français", note: 9 }
    ]
  },
  {
    nom: "Bob",
    notes: [
      { matiere: "maths", note: 8 },
      { matiere: "français", note: 16 }
    ]
  }
]);
```

---

## Démo : faux positif vs bonne pratique

```js
// Sans $elemMatch : chaque critère peut matcher un élément différent du tableau
// => faux positif possible
db.etudiants.find({
  "notes.matiere": "maths",
  "notes.note": { $gt: 15 }
});

// Avec $elemMatch : les conditions doivent matcher le même élément
db.etudiants.find({
  notes: { $elemMatch: { matiere: "maths", note: { $gt: 15 } } }
});
```

---

## Compter

```js
db.restaurants.countDocuments({ borough: "Manhattan" });
```

---

## Aide pour les exercices (mapping rapide)

Exemples :

```js
// Ex 2 (AND + projection)
db.restaurants.find({ borough: "Manhattan", cuisine: "Italian" }, { name: 1, "address.zipcode": 1, _id: 0 });

// Ex 3 ($in + countDocuments)
db.restaurants.countDocuments({ borough: { $in: ["Bronx", "Queens", "Brooklyn"] } });

// Ex 6 (tri + pagination)
db.restaurants.find({ borough: "Queens" }, { name: 1, _id: 0 }).sort({ name: 1 }).skip(10).limit(10);
```

---

## À retenir

- `find` = lecture + filtres + projection + tri
- Toujours `limit` + projection quand possible (perf + réseau)
- Les filtres sur tableaux nécessitent souvent `$elemMatch`

---

## Exercices

- Exercices (8) : `Exercices/mongodb_02_modele_document_bson.md`
