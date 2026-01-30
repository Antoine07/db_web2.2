---
marp: true
title: "SQL (PostgreSQL) — 01. Installation PostgreSQL (Docker Compose)"
paginate: true
header: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
footer: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
---

# 01 — Installation PostgreSQL
## Docker Compose (TPs)

---

## Objectif

- Lancer PostgreSQL via `docker compose`
- Savoir se connecter en CLI (`psql`)
- Importer la base `shop` (schéma + données `seed`)

---

## Pré-requis

- Docker Desktop installé
- Le `docker-compose.yml` du TP (dossier `TPs/app-project-starter/` ou votre copie)

---

## 1) Lancer PostgreSQL (Docker Compose)

Depuis le dossier qui contient le `docker-compose.yml` du TP :

```bash
docker compose up -d
```

Par défaut :
- Postgres dans le conteneur : `postgres:5432`
- Postgres sur votre machine : `localhost:5433`

---

## 2) Se connecter en CLI (dans le conteneur)

```bash
docker compose exec postgres psql -U postgres -d shop
```

Identifiants (TP) :
- user : `postgres`
- password : `postgres`
- database : `shop`

---

## 3) Vérifier que Postgres répond

Dans `psql` :

```sql
SELECT version();
```

Commandes utiles `psql` :
- `\l` (liste des bases)
- `\dt` (tables)
- `\d customers` (structure d'une table)

---

## 4) Seed de la base `shop` (recommandé : script du TP)

```bash
docker compose exec postgres psql -U postgres -d shop -v ON_ERROR_STOP=1 -f /shared/postgres/seed.sql
```

---

## Alternative — importer depuis `data/` (si vous avez `psql` en local)

Si Postgres est exposé en `5433` (docker) :

```bash
psql -h 127.0.0.1 -p 5433 -U postgres -d shop -v ON_ERROR_STOP=1 -f data/shop_schema_postgres.sql
psql -h 127.0.0.1 -p 5433 -U postgres -d shop -v ON_ERROR_STOP=1 -f data/shop_seed_postgres.sql
psql -h 127.0.0.1 -p 5433 -U postgres -d shop
```

---

## Adminer (optionnel)

Ouvrez : `http://localhost:8080`

Connexion typique :
- Système : `PostgreSQL`
- Serveur : `postgres`
- Utilisateur : `postgres`
- Mot de passe : `postgres`
- Base : `shop`
