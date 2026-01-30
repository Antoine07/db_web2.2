# Exercices MongoDB — 01. Installation et setup

## Objectif

Être capable de se connecter à MongoDB et de charger le dataset `restaurants.json` (collection `restaurants`).

## Exercice 1 — Se connecter avec `mongosh`

1) Lancez `mongosh` (local, Docker ou Atlas)  
2) Affichez la version : `mongosh --version`

## Exercice 2 — Importer le dataset `restaurants.json` (Docker du repo)

Depuis `starter/` :

```bash
docker compose up -d

# récupérer les données (si besoin)
curl -L "https://raw.githubusercontent.com/mongodb/docs-assets/primer-dataset/primer-dataset.json" \
  -o shared/mongodb/restaurants.json

docker exec -i mongo-container mongoimport \
  --db ny_restaurants \
  --collection restaurants \
  --authenticationDatabase admin \
  --username root \
  --password root \
  --drop \
  --file /shared/restaurants.json
```

## Exercice 3 — Vérifications rapides

Dans `mongosh` :

1) Ouvrez la base `ny`  
2) Affichez un restaurant (`findOne`)  
3) Comptez le nombre de restaurants (`countDocuments`)

## Exercice 4 — Explorer un document

Récupérez un restaurant et identifiez :
- `address` (objet imbriqué)
- `address.coord` (tableau)
- `grades` (tableau)
- `grades.date` (type attendu ?)
