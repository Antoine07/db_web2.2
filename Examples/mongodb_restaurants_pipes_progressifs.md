# Exemples MongoDB — Pipelines `aggregate()` progressifs (dataset `restaurants`)

Pré-requis :
- base : `ny_restaurants`
- collection : `restaurants`
- dataset importé depuis `shared/mongodb/restaurants.json` (volume Docker → `/shared/restaurants.json`)

Dans `mongosh` :

```js
use("ny_restaurants");
```

---

## 1) Lire un pipeline (méthode)

On lit un pipeline comme une chaîne de transformations : chaque étape reçoit des documents en entrée et renvoie des documents en sortie.

Bon réflexe :
- commencer avec `$match` + `$limit`
- ajouter **une seule** étape à la fois
- réduire le volume tôt (`$match`, `$project`)

---

## 2) Pipeline minimal : `$match` + `$project` + `$limit`

Objectif : voir des restaurants de Manhattan et ne garder que quelques champs.

```js
let res =  db.restaurants.aggregate([
  { $match: { borough: "Manhattan" } },
  { $project: { _id: 0, name: 1, cuisine: 1, borough: 1, "address.zipcode": 1 } },
  { $limit: 5 }
])


const res = db.restaurants.find({})

for(const el of res){
  console.log(el)
}
```

---

## 3) Ajouter un tri : `$sort`

```js
db.restaurants.aggregate([
  { $match: { borough: "Manhattan" } },
  { $project: { _id: 0, name: 1, cuisine: 1 } },
  { $sort: { name: 1 } },
  { $limit: 10 }
]);
```

---

## 4) Ajouter un champ calculé : `$addFields` / `$set`

Objectif : construire un “label” lisible.

```js
db.restaurants.aggregate([
  { $match: { borough: "Queens" } },
  {
    $set: {
      label: { $concat: ["$name", " (", "$cuisine", ")"] },
      zipcode: "$address.zipcode"
    }
  },
  { $project: { _id: 0, label: 1, borough: 1, zipcode: 1 } },
  { $limit: 10 }
]);
```

---

## 5) Travailler avec un tableau SANS `$unwind` : `$size`

`grades` est un tableau d’inspections. On peut compter le nombre d’éléments.

```js
db.restaurants.aggregate([
  { $match: { borough: "Bronx" } },
  { $project: { _id: 0, name: 1, borough: 1, gradesCount: { $size: "$grades" } } },
  { $sort: { gradesCount: -1 } },
  { $limit: 10 }
]);
```

---

## 6) Passer au niveau “inspection” : `$unwind`

Après `$unwind: "$grades"`, 1 restaurant devient N documents (1 par inspection).

Objectif : lister des inspections “C” (on voit l’inspection, pas seulement le restaurant).

```js
db.restaurants.aggregate([
  { $unwind: "$grades" },
  { $match: { "grades.grade": "C" } },
  { $project: { _id: 0, name: 1, borough: 1, cuisine: 1, grade: "$grades.grade", score: "$grades.score" } },
  { $limit: 10 }
]);
```

---

## 7) Exemple parlant : “pires inspections” (score élevé)

Rappel (dataset NYC) : plus le score est élevé, plus l’inspection est mauvaise.

```js
db.restaurants.aggregate([
  { $match: { borough: "Manhattan" } },
  { $unwind: "$grades" },
  { $sort: { "grades.score": -1 } },
  { $project: { _id: 0, name: 1, cuisine: 1, borough: 1, score: "$grades.score", grade: "$grades.grade" } },
  { $limit: 10 }
]);
```

---

## 8) Agréger : moyenne par cuisine (avec `$group`)

Objectif : score moyen d’inspection par cuisine (Manhattan).

```js
db.restaurants.aggregate([
  { $match: { borough: "Manhattan" } },
  { $unwind: "$grades" },
  { $group: { _id: "$cuisine", avgScore: { $avg: "$grades.score" }, inspections: { $sum: 1 } } },
  { $sort: { avgScore: -1 } },
  { $limit: 10 }
]);
```

---

## 9) Agréger : top restaurants par score moyen (min 3 inspections)

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

## 10) Deux rapports en une requête : `$facet`

Objectif : obtenir en un seul appel :
- top cuisines (Manhattan)
- nombre de restaurants par borough

```js
db.restaurants.aggregate([
  {
    $facet: {
      topCuisinesManhattan: [
        { $match: { borough: "Manhattan" } },
        { $group: { _id: "$cuisine", count: { $sum: 1 } } },
        { $sort: { count: -1 } },
        { $limit: 10 }
      ],
      byBorough: [
        { $group: { _id: "$borough", count: { $sum: 1 } } },
        { $sort: { count: -1 } }
      ]
    }
  }
]);
```

---

## 11) Faire une “distribution” de scores : `$bucket`

Objectif : compter les inspections par tranche de score.

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

## 12) `$lookup` (optionnel) : enrichir avec une collection de référence

Le dataset `restaurants` ne fournit qu’une collection. Pour illustrer `$lookup`, on peut créer une collection `boroughs`.

```js
db.boroughs.drop();
db.boroughs.insertMany([
  { _id: "Manhattan", area: "NYC" },
  { _id: "Brooklyn", area: "NYC" },
  { _id: "Queens", area: "NYC" },
  { _id: "Bronx", area: "NYC" },
  { _id: "Staten Island", area: "NYC" }
]);
```

Puis jointure :

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
  { $project: { _id: 0, name: 1, cuisine: 1, borough: 1, area: "$borough_info.area" } },
  { $limit: 10 }
]);
```

---

# Manipuler les résultats en JavaScript (dans `mongosh`)

`mongosh` est une console JavaScript : on peut stocker des résultats dans des variables et manipuler des objets/arrays.

## 1) Lire un document et accéder aux champs

```js
const doc = db.restaurants.findOne({ borough: "Manhattan" });
doc.name;
doc.address.zipcode;
doc.grades[0].score;
doc["restaurant_id"];
```

Sécurité (si une propriété peut être absente) :

```js
doc.address?.zipcode;
doc.grades?.[0]?.score;
```

---

## 2) Travailler avec un curseur `find()`

`find()` renvoie un curseur (lazy). Pour obtenir une vraie liste JS :

```js
const list = db.restaurants.find({ borough: "Queens" }, { name: 1, _id: 0 }).limit(5).toArray();
list[0].name;
```

Ou itérer sans tout charger :

```js
db.restaurants.find({ borough: "Queens" }, { name: 1, _id: 0 }).limit(5).forEach(r => print(r.name));
```

---

## 3) Récupérer le résultat d’un `aggregate()` en JS

```js
const res = db.restaurants
  .aggregate([{ $group: { _id: "$borough", count: { $sum: 1 } } }, { $sort: { count: -1 } }])
  .toArray();

res[0]._id;
res[0].count;
```

---

## 4) Utiliser `map` / `filter` / `reduce` sur les résultats

```js
const boroughs = res.map(x => x._id);
const big = res.filter(x => x.count > 5000);
const total = res.reduce((acc, x) => acc + x.count, 0);
```

---

## 5) Afficher proprement

```js
printjson(doc);
printjson(res[0]);
```

Dans `mongosh`, la variable `it` correspond souvent au dernier résultat affiché (pratique pour explorer).


```js
db.restaurants.aggregate([
  { $match: { borough: "Manhattan", cuisine: "Italian" } },
  { $project: { name: 1, borough: 1, cuisine: 1, _id: 1 } },
  { $limit: 10 }
]);

db.restaurants.aggregate([
  { $match: { borough: "Manhattan" } },
  { $project: { cuisine: 1, grades: 1, _id: 1 } },
  { $unwind: "$grades" },
  { $limit: 4 }
]);

db.restaurants.aggregate([
  { $match: { borough: "Manhattan" } },
  { $project: { cuisine: 1, grades: 1, _id: 1 } },
  { $limit: 4 }
]);


for await (const doc of db.restaurants.find()) {
  console.log(doc);
}
```