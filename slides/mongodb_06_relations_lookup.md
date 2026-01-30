---
marp: true
title: "MongoDB — 05. `$lookup` : joindre des collections"
paginate: true
header: "[← Index MongoDB](https://antoine07.github.io/db_web2.2/mongodb_index.html)"
footer: "[← Index MongoDB](https://antoine07.github.io/db_web2.2/mongodb_index.html)"
---

# MongoDB — 05
## `$lookup` (join entre collections)

---

## Pré-requis : `aggregate` (pipeline)

`$lookup` s’utilise dans un pipeline :

```js
db.restaurants.aggregate([
  { $match: { borough: "Manhattan" } },
  { $limit: 3 }
]);
```

Rappel : `aggregate([...])` prend **un tableau d’étapes** (stages).

---

## Structure d’un `$lookup`

```js
{
  $lookup: {
    from: "boroughs",
    localField: "borough",
    foreignField: "_id",
    as: "borough_info"
  }
}
```

- `from` : collection cible
- `localField` : champ côté `restaurants`
- `foreignField` : champ côté collection joinée
- `as` : nom du champ résultat (tableau)

---

## Embedding (dans le dataset)

Les inspections (`grades[]`) sont "embeddées" dans `restaurants` :

```js
use("ny_restaurants");
db.restaurants.findOne({}, { name: 1, grades: 1, _id: 0 });
```

---

## References (quand on veut enrichir)

Le dataset `restaurants` n'a qu'une collection, donc on crée une collection de référence (ex: `boroughs`).

```js
db.boroughs.insertMany([
  { _id: "Manhattan", area: "NYC", note: "Île + downtown/midtown/uptown" },
  { _id: "Brooklyn", area: "NYC", note: "Sud/Est de Manhattan" },
  { _id: "Queens", area: "NYC", note: "A l'est" },
  { _id: "Bronx", area: "NYC", note: "Au nord" },
  { _id: "Staten Island", area: "NYC", note: "Sud-ouest" }
]);
```

---

## `$lookup` (équivalent "join")

```js
db.restaurants.aggregate([
  { $match: { borough: "Manhattan" } },
  {
    $lookup: {
      from: "boroughs",
      localField: "borough",
      foreignField: "_id",
      as: "borough_info"
    }
  },
  { $unwind: "$borough_info" },
  { $project: { name: 1, cuisine: 1, borough: 1, borough_info: 1 } },
  { $limit: 5 }
]);
```

---

## Pourquoi `$unwind` ici ?

Après `$lookup`, `borough_info` est un **tableau** (même si un seul match).

```js
{ $unwind: "$borough_info" }
```

→ transforme “1 doc avec tableau” en “1 doc avec objet”.

Alternative si on veut garder les restaurants même sans match :

```js
{ $unwind: { path: "$borough_info", preserveNullAndEmptyArrays: true } }
```

---

## `$lookup` → pourquoi un tableau ?

`$lookup` ajoute toujours un **tableau** dans le champ `as` :

- si 0 match → `[]`
- si 1 match → `[ { ... } ]`
- si N match → `[ { ... }, { ... }, ... ]`

Donc `$unwind` sert à “aplatir” quand on veut manipuler l’objet directement.

---

## `$unwind` après `$lookup` : effets à connaître

```js
{ $unwind: "$borough_info" }
```

- si `borough_info` contient **1 élément** → 1 doc en sortie (le cas le plus courant ici)
- si `borough_info` contient **N éléments** → N docs en sortie (duplication des champs du restaurant)
- si `borough_info` est vide/manquant → le doc est supprimé (sauf `preserveNullAndEmptyArrays: true`)

---

## Alternative à `$unwind` (si on veut “juste le 1er match”)

Si on sait qu’il ne peut y avoir qu’un match (ou qu’on accepte d’en prendre un seul) :

```js
db.restaurants.aggregate([
  {
    $lookup: {
      from: "boroughs",
      localField: "borough",
      foreignField: "_id",
      as: "borough_info"
    }
  },
  { $set: { borough_info: { $arrayElemAt: ["$borough_info", 0] } } }
]);
```

Ça évite la multiplication de documents (mais on perd l’info “multi-match”).

---

## Quand utiliser `$lookup` ?

- Lecture "back-office" (reporting, admin)
- Cas où la duplication serait trop coûteuse
- À éviter en boucle sur des gros volumes sans index

---

## À retenir

- MongoDB n'interdit pas les relations : il propose plusieurs patterns
- `embedding` simplifie la lecture, `references` simplifie la mise à jour

---

## Exercices

- Exercices : `Exercices/mongodb_06_relations_lookup.md`
