# API Node (sans Express)

Mini API HTTP (Node.js natif) :

- `GET /api/pg/customers` → customers (Postgres)

## Prérequis

1) Démarrer les bases (docker) :

```bash
cd corrections/TPs/app-project
docker compose up -d
```

2) Seed à la main (optionnel si déjà fait) :

```bash
docker compose exec postgres psql -U postgres -d postgres -v ON_ERROR_STOP=1 -c "CREATE DATABASE shop;"
docker compose exec postgres psql -U postgres -d shop -v ON_ERROR_STOP=1 -f /shared/postgres/seed.sql
```

3) Installer et lancer l’API :

```bash
cd corrections/TPs/app-project/api
pnpm i
pnpm run dev
```

## Variables d’environnement (optionnel)

- `PORT` (défaut `4000`)
- `PG_CONNECTION_STRING` (défaut `postgresql://postgres:postgres@localhost:5433/shop`)

Le `docker-compose.yml` expose Postgres sur le port hôte `5433` pour éviter les conflits avec un Postgres local sur `5432`.

Si tu veux utiliser ton Postgres local (sans user `postgres`) :
- `PG_CONNECTION_STRING="postgresql://$USER@localhost:5432/shop" pnpm run dev`
