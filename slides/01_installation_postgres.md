---
marp: true
title: "SQL (PostgreSQL) — 01. Installation PostgreSQL"
paginate: true
header: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
footer: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
---

# 01 — Installation PostgreSQL
## Docker, macOS, Windows

---

## Objectif

- demarrer PostgreSQL
- charger la base `shop`
- verifier que tout fonctionne

---

## Option A (recommandee) — Docker

Depuis la racine du projet :

```bash
cd starter-db
docker compose up -d postgres adminer
```

Ports par defaut :
- Postgres : `5433`
- Adminer : `8080`

Si conflit de ports :

```bash
POSTGRES_PORT=55433 ADMINER_PORT=8083 docker compose up -d postgres adminer
```

---

## Option A — Charger la base (commande unique)

```bash
docker compose exec -T postgres \
  psql -U postgres -d shop -v ON_ERROR_STOP=1 -f /shared/seed.sql
```

---

## Option A — Verifier rapidement

```bash
docker compose exec -T postgres psql -U postgres -d shop -c "SELECT COUNT(*) AS products FROM products;"
docker compose exec -T postgres psql -U postgres -d shop -c "SELECT COUNT(*) AS customers FROM customers;"
```

Attendu :
- `products = 8`
- `customers = 5`

---

## Option B — macOS (sans Docker)

Install simple:
- Postgres.app (ou Homebrew)

Puis dans un terminal :

```bash
createdb shop
psql -d shop -v ON_ERROR_STOP=1 -f data/shop_schema_postgres.sql
psql -d shop -v ON_ERROR_STOP=1 -f data/shop_seed_postgres.sql
psql -d shop -c "SELECT COUNT(*) AS products FROM products;"
```

---

## Option C — Windows (sans Docker)

Install simple:
- installateur PostgreSQL officiel (inclut `psql` + pgAdmin)

Puis (PowerShell) :

```powershell
psql -U postgres -d postgres -c "CREATE DATABASE shop;"
psql -U postgres -d shop -v ON_ERROR_STOP=1 -f data\shop_schema_postgres.sql
psql -U postgres -d shop -v ON_ERROR_STOP=1 -f data\shop_seed_postgres.sql
psql -U postgres -d shop -c "SELECT COUNT(*) AS products FROM products;"
```

Si `psql` non reconnu:
- ajouter `...\PostgreSQL\<version>\bin` au `PATH`

---

## Sans Docker : outil recommande

- Recommande : `pgAdmin` (installe avec PostgreSQL sur Windows)
- Alternative : DBeaver / TablePlus / DataGrip
- CLI minimale : `psql` suffit pour tout le chapitre
