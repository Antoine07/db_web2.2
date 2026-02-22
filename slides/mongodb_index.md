---
marp: true
title: "Cours MongoDB — Plan"
description: "Plan du cours MongoDB + fil rouge + exercices"
paginate: true
---

# Cours MongoDB

---

## Objectifs

- Comprendre la structure du dataset `restaurants.json`
- Maîtriser `find` (filtres, projection, tri)
- Passer à `aggregate` (bases puis pipes avancés)
- Comprendre `$lookup` (join entre collections)
- Valider un schéma côté MongoDB (JSON Schema)
- Valider un schéma côté TypeScript (runtime + types)

---

## Fil rouge (utilisé dans tous les chapitres)

Base `ny_restaurants` :
- collection `restaurants`

Dataset : `restaurants.json` (import via `mongoimport`)

---

## Démarrage rapide (fil rouge `ny_restaurants`)

Depuis `starter/` :

```bash
docker compose up -d

curl -L "https://raw.githubusercontent.com/mongodb/docs-assets/primer-dataset/primer-dataset.json" \
  -o shared/mongodb/restaurants.json

docker compose exec -T mongodb mongoimport \
  --db ny_restaurants \
  --collection restaurants \
  --authenticationDatabase admin \
  --username root \
  --password root \
  --drop \
  --file /shared/restaurants.json
```

Puis dans `mongosh` :

```js
use("ny_restaurants");
db.restaurants.findOne();
```

---

## Chapitres

1. [MongoDB — 01 — Dataset restaurants : présentation + import](https://antoine07.github.io/db_web2.2/mongodb_01_installation_mongodb.html)
2. [MongoDB — 02 — Requêtes de base : `find`](https://antoine07.github.io/db_web2.2/mongodb_02_modele_document_bson.html)
3. [MongoDB — 03 — Agrégation (1) : bases](https://antoine07.github.io/db_web2.2/mongodb_08_aggregation_pipeline.html)
4. [MongoDB — 04 — Agrégation (2) : pipes avancés](https://antoine07.github.io/db_web2.2/mongodb_09_indexation_performance.html)
5. [MongoDB — 05 — `$lookup` : joindre des collections](https://antoine07.github.io/db_web2.2/mongodb_06_relations_lookup.html)
6. [MongoDB — 06 — Validation : JSON Schema](https://antoine07.github.io/db_web2.2/mongodb_03_collections_validation_schema.html)
7. [MongoDB — 07 — TypeScript + MongoDB : double validation](https://antoine07.github.io/db_web2.2/mongodb_11_typescript_mongodb_validation.html)
