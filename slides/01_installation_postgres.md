---
marp: true
title: "SQL (PostgreSQL) — 01. Installation PostgreSQL (Docker Compose)"
paginate: true
header: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
footer: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
---

# 01 — Installation PostgreSQL
## Version simple et testee

---

## Objectif

- demarrer PostgreSQL
- charger la base `shop`
- verifier que tout fonctionne

---

## 1) Demarrer les services

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

## 2) Charger la base (commande unique, recommande)

```bash
docker compose exec -T postgres \
  psql -U postgres -d shop -v ON_ERROR_STOP=1 -f /shared/seed.sql
```

---

## 3) Verifier rapidement

```bash
docker compose exec -T postgres psql -U postgres -d shop -c "SELECT COUNT(*) AS products FROM products;"
docker compose exec -T postgres psql -U postgres -d shop -c "SELECT COUNT(*) AS customers FROM customers;"
```

Attendu :
- `products = 8`
- `customers = 5`

---

## Option Adminer (si vous preferez l'interface web)

1. Ouvrir `http://localhost:8080` (ou `http://localhost:8083` si port custom)
2. Se connecter avec :
- Systeme : `PostgreSQL`
- Serveur : `postgres`
- Utilisateur : `postgres`
- Mot de passe : `postgres`
- Base : `shop`
3. Onglet SQL -> copier/coller le contenu de `starter-db/shared/postgres/seed.sql` -> Executer

---

## TL;DR

Utilisez seulement ces 2 commandes :

```bash
cd starter-db && docker compose up -d postgres adminer
docker compose exec -T postgres psql -U postgres -d shop -v ON_ERROR_STOP=1 -f /shared/seed.sql
```
