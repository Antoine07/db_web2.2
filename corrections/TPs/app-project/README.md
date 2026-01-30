# App Project — Docker (Postgres + MongoDB + Adminer)

Ce dossier fournit un environnement Docker prêt à l’emploi pour les exercices :
- **Postgres 17** (base relationnelle)
- **MongoDB 7** (base document)
- **Adminer** (interface web pour Postgres)

Les données d’exemple utilisées reprennent le fil rouge **`shop`** (mêmes tables + mêmes données que celles du dossier `data/` du repo).

## Prérequis

- Docker Desktop (ou Docker Engine)
- La commande `docker compose` (ou `docker-compose`)
- pnpm (via Corepack recommandé)

```bash
corepack enable
corepack prepare pnpm@9.15.5 --activate
```

## Démarrage rapide

Depuis la racine du repo :

```bash
cd corrections/TPs/app-project
docker compose up -d
```

Ensuite, faites le seed à la main en exécutant les scripts dans les conteneurs.

### Seed Postgres (shop)

```bash
docker compose exec postgres psql -U postgres -d postgres -v ON_ERROR_STOP=1 -c "CREATE DATABASE shop;"
docker compose exec postgres psql -U postgres -d shop -v ON_ERROR_STOP=1 -f /shared/postgres/seed.sql
```

### Seed MongoDB (shop)

```bash
docker compose exec mongodb mongosh -u root -p root --authenticationDatabase admin --file /shared/mongodb/seed.js
```

## API Node (sans Express)

Une mini API HTTP est dispo dans `app-project/api` :

- `GET /api/pg/customers` (Postgres)

Démarrage :

```bash
cd corrections/TPs/app-project/api
pnpm i
pnpm run dev
```

## App React (TanStack Query)

L’app React est dans `app-project/client` et consomme l’API via un proxy Vite (`/api` → `http://localhost:4000`).

```bash
cd corrections/TPs/app-project/client
pnpm i
pnpm run dev
```

## Monorepo pnpm (API + client)

Depuis `corrections/TPs/app-project/` :

```bash
pnpm i
pnpm run dev
```

> Note : MongoDB est bien démarré par `docker compose up`, et le seed est manuel (commande ci-dessus). L’API ne l’expose pas pour l’instant.

## Accès aux services

### Adminer (Postgres)

- URL : `http://localhost:8080`
- Système : `PostgreSQL`
- Serveur : `postgres` (si vous êtes dans le réseau Docker) ou `localhost` (depuis votre machine)
- Utilisateur : `postgres`
- Mot de passe : `postgres`
- Base : `shop`

### Postgres

- Port hôte : `5433`
- Base : `shop`
- Utilisateur / mot de passe : `postgres` / `postgres`

Le `docker-compose.yml` utilise `5433:5432` pour éviter les conflits avec un Postgres local sur `5432`.

Connexion en ligne de commande (dans le conteneur) :
```bash
docker compose exec postgres psql -U postgres -d shop
```

### MongoDB

- Port hôte : `27017`
- Auth admin : `root` / `root` (base d’authentification : `admin`)
- Base de travail seedée : `shop`

Exemple de connexion (MongoDB Compass / client) :
`mongodb://root:root@localhost:27017/?authSource=admin`

Connexion en ligne de commande (dans le conteneur) :
```bash
docker compose exec mongodb mongosh -u root -p root --authenticationDatabase admin
```

## Structure des fichiers (données / seeds)

- Partage monté dans les conteneurs (lecture seule) : `app-project/shared` → `/shared`
- Seed Postgres : `app-project/shared/postgres/seed.sql`
- Seed MongoDB : `app-project/shared/mongodb/seed.js`
- Références MySQL (source des données du fil rouge `shop`) :
  - `app-project/shared/mysql/shop_schema.sql`
  - `app-project/shared/mysql/shop_seed.sql`
  - `app-project/shared/mysql/shop_json_evolution.sql`

## Détails du `docker-compose.yml`

Fichier : `app-project/docker-compose.yml`

- Service `postgres`
  - Image : `postgres:17-alpine`
  - Variables : `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB=shop`
  - Volume persistant : `postgres_data` (vos données restent si vous redémarrez)
  - Montage : `./shared:/shared:ro` (données/seed accessibles dans le conteneur)
  - Healthcheck : `pg_isready`

- Service `mongodb`
  - Image : `mongo:7`
  - Variables : `MONGO_INITDB_ROOT_USERNAME`, `MONGO_INITDB_ROOT_PASSWORD`, `MONGO_INITDB_DATABASE=shop`
  - Volume persistant : `mongo_data`
  - Montage : `./shared:/shared:ro`
  - Healthcheck : ping via `mongosh`

- Service `adminer`
  - Image : `adminer:4`
  - Port : `8080`
  - Dépend de `postgres` (pour éviter de démarrer avant Postgres)

## Commandes utiles

- Voir l’état : `docker compose ps`
- Logs : `docker compose logs -f`
- Stop (sans effacer les données) : `docker compose down`
- Reset complet (efface aussi les volumes !) : `docker compose down -v`

## Problèmes fréquents

- Port déjà utilisé (`5432` ou `27017`) : changez le mapping dans `docker-compose.yml` (ex: `5433:5432`) puis relancez.
