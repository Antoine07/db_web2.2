---
marp: true
title: "MongoDB — 05. Requêtes de base"
paginate: true
header: "[← Index MongoDB](https://antoine07.github.io/db_web2.2/mongodb_index.html)"
footer: "[← Index MongoDB](https://antoine07.github.io/db_web2.2/mongodb_index.html)"
---

# MongoDB — 05
## `find`, filtres, tri, pagination

---

## Préparation

```js
use("ny_restaurants");
```

---

## Trouver des documents

```js
db.restaurants.find().limit(3);
db.restaurants.find({ borough: "Manhattan" }).limit(3);
```

---

## Projection (choisir les champs)

```js
db.restaurants.find(
  { borough: "Brooklyn" },
  { name: 1, cuisine: 1, "address.zipcode": 1, _id: 0 }
).limit(10);
```

---

## Tri + pagination

```js
db.restaurants.find({}, { name: 1, borough: 1, _id: 0 })
  .sort({ name: 1 })
  .skip(20)
  .limit(10);
```

---

## Opérateurs courants

- Comparaisons : `$eq`, `$ne`, `$gt`, `$gte`, `$lt`, `$lte`
- Ensembles : `$in`, `$nin`
- Texte : `$regex` (avec prudence)
- Tableaux : `$all`, `$elemMatch`

---

## Filtres sur champs imbriqués

```js
db.restaurants.find({ "address.zipcode": "11215" }, { name: 1, _id: 0 }).limit(10);
```

---

## À retenir

- `find(query, projection)` + `sort/limit/skip` = base du "SELECT"
- Toujours limiter/projeter si besoin (perf + réseau)

---

## Exercices

- Exercices : `Exercices/mongodb_05_requetes_de_base.md`
