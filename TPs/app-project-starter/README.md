# App Project — Starter TP

Ce dossier est un starter à copier pour le TP.

- `docker-compose.yml` : Postgres + MongoDB + Adminer
- `shared/` : scripts de seed (Postgres + MongoDB)
- `api/` : mini API Node (sans Express) — fournie et commentée
- `client/` : squelette React (fetch) — à refactorer ensuite avec TanStack Query
- (Nouveau) Monorepo `pnpm` : install + dev depuis la racine du starter

## Démarrage rapide

```bash
docker compose up -d
docker compose exec postgres psql -U postgres -d shop -v ON_ERROR_STOP=1 -f /shared/postgres/seed.sql
pnpm i

# 2 terminaux (recommandé)
pnpm run dev:api
pnpm run dev:client

# ou lancer les 2 à la fois
pnpm run dev
```

## Installer pnpm (si besoin)

Avec Corepack (recommandé) :

```bash
corepack enable
corepack prepare pnpm@9.15.5 --activate
```

## Installer tout le monorepo (depuis la racine du repo)

```bash
pnpm i
```
