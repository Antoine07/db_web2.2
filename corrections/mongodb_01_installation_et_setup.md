# Corrections MongoDB — 01. Installation et setup

## Exercice 1 — Se connecter avec `mongosh`

```bash
mongosh --version
mongosh "mongodb://localhost:27017"
```

## Exercice 2 — Importer le dataset `restaurants.json` (Docker du repo)

Depuis `starter/` :

```bash
docker compose up -d

# récupérer les données (si besoin)
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

## Exercice 3 — Vérifications rapides

```js
use("ny_restaurants");
db.restaurants.findOne();
db.restaurants.countDocuments();
```

## Exercice 4 — Explorer un document

```js
db.restaurants.findOne({}, { address: 1, grades: 1 });
```

- `address` : objet
- `address.coord` : tableau (coordonnées lon/lat)
- `grades` : tableau
- `grades.date` : `Date` (`ISODate(...)`)
