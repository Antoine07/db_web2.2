---
marp: true
title: "MongoDB — 01. Dataset restaurants : présentation + import"
paginate: true
header: "[← Index MongoDB](https://antoine07.github.io/db_web2.2/mongodb_index.html)"
footer: "[← Index MongoDB](https://antoine07.github.io/db_web2.2/mongodb_index.html)"
---

# MongoDB — 01
## Présentation des données (`restaurants.json`)

---

## Objectif du fil rouge

- Base : `ny_restaurants`
- Collection : `restaurants`
- S’entraîner sur : `find`, `aggregate`, `$lookup`, validation

---

## Importer le dataset

Depuis `starter/` :

```bash
docker compose up -d

# récupérer les données (si besoin)
curl -L "https://raw.githubusercontent.com/mongodb/docs-assets/primer-dataset/primer-dataset.json" \
  -o shared/mongodb/restaurants.json

# import: base `ny_restaurants`, collection `restaurants`
docker exec -i mongo-container mongoimport \
  --db ny_restaurants \
  --collection restaurants \
  --authenticationDatabase admin \
  --username root \
  --password root \
  --drop \
  --file /shared/restaurants.json
```

---

## Connexion `mongosh`

```bash
docker exec -it mongo-container mongosh \
  "mongodb://root:root@localhost:27017/ny_restaurants?authSource=admin"
```

---

## Node.js + MongoDB (Docker uniquement pour MongoDB)

### Lancer MongoDB avec Docker Compose (seul)

```yaml
services:
  mongodb:
    image: mongo:7
    ports:
      - "27017:27017"
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: root
```

---

### URI de connexion

- **Node sur ta machine** (hors Docker) :
  - `mongodb://root:root@localhost:27017/ny_restaurants?authSource=admin`
- **Node dans Docker** (même compose) :
  - `mongodb://root:root@mongodb:27017/ny_restaurants?authSource=admin`

---

## Exemple minimal (driver officiel)

```js
import { MongoClient } from "mongodb";

const client = new MongoClient(process.env.MONGODB_URI);
await client.connect();

const db = client.db("ny_restaurants");
const count = await db.collection("restaurants").countDocuments();
console.log({ count });

await client.close();
```

---

## Le dataset (structure)

```js
use("ny_restaurants");
db.restaurants.findOne();
```

Champs typiques :
- `restaurant_id`, `name`, `borough`, `cuisine`
- `address` : `building`, `street`, `zipcode`, `coord` (tableau)
- `grades[]` : `{ date, grade, score }`

---

## Types BSON à repérer

```js
// ObjectId
db.restaurants.findOne({}, { _id: 1 });

// Date (import depuis Extended JSON)
db.restaurants.findOne({}, { grades: { $slice: 1 } });
```

---

## 3 commandes indispensables

```js
use("ny_restaurants");
db.restaurants.countDocuments();
db.restaurants.find({}, { name: 1, borough: 1, cuisine: 1, _id: 0 }).limit(5);
db.restaurants.find({ borough: "Manhattan" }).limit(3);
```

---

## Exercices

- Exercices : `Exercices/mongodb_01_installation_et_setup.md`
