---
marp: true
title: "SQL (MySQL) — 01. Installation MySQL"
paginate: true
header: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
footer: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
---

# 01 — Installation MySQL

> Variante MySQL transcrite depuis le parcours PostgreSQL (adapter les syntaxes spécifiques).

## Version simple

---

## Objectif

- demarrer MySQL
- charger la base `shop`
- verifier que tout fonctionne

---

## Option A — macOS (sans Docker)

Installation:
- MySQL Community Server + MySQL Workbench
- ou Homebrew (`brew install mysql`)

```bash
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS shop;"
mysql -u root -p < data/shop_schema_mysql.sql
mysql -u root -p < data/shop_seed_mysql.sql
mysql -u root -p -D shop -e "SELECT COUNT(*) AS products FROM products;"
```

---

## Option B — Windows (sans Docker)

Installation:
- MySQL Installer (Server + Workbench)
- client CLI `mysql` inclus

PowerShell:

```powershell
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS shop;"
mysql -u root -p < data\shop_schema_mysql.sql
mysql -u root -p < data\shop_seed_mysql.sql
mysql -u root -p -D shop -e "SELECT COUNT(*) AS products FROM products;"
```

---

## Verifications attendues

```bash
mysql -u root -p -D shop -e "SELECT COUNT(*) AS products FROM products;"
mysql -u root -p -D shop -e "SELECT COUNT(*) AS customers FROM customers;"
```

- `products = 8`
- `customers = 5`

---

## Outils conseilles (sans Docker)

- GUI: MySQL Workbench (ou DBeaver)
- CLI: `mysql`

---

## TL;DR

```bash
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS shop;"
mysql -u root -p < data/shop_schema_mysql.sql
mysql -u root -p < data/shop_seed_mysql.sql
```
