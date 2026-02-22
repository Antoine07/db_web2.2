---
marp: true
title: "SQL (PostgreSQL) — 12. Analyse de données"
paginate: true
header: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
footer: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
---

# 12 — Analyse de donnees avec PostgreSQL
## Introduction ETL + modelisation analytique

---

## Objectif du chapitre

Avant de calculer des KPI, on doit:
- nettoyer les donnees (ETL)
- structurer un modele analytique (dimensions + faits)
- seulement ensuite faire des requetes d'analyse

Pipeline du chapitre:
`CSV brut -> Python ETL -> CSV propre -> modele PostgreSQL -> KPI`

---

## 1) Jeu de donnees brut (demo)

Fichier:
- `data/sales_raw_etl_demo.csv`

Problemes volontaires dans ce dataset:
- formats de date differents (`2026-01-02`, `02/01/2026`, `2026/01/03`)
- doublon de ligne
- email invalide
- quantite manquante ou negative
- prix invalide (`abc`) ou format decimal avec virgule (`79,90`)
- statuts heterogenes (`paid`, `PAID`, `Paid`, `pending`, `refunded`)

---

## 2) ETL de nettoyage en Python

Script:
- `scripts/etl_sales_clean.py`

Execution:

```bash
python3 scripts/etl_sales_clean.py
```

Le script:
- garde uniquement les ventes `paid`
- normalise date / email / textes
- gere les quantites (valeur vide -> `1`)
- elimine lignes invalides et doublons
- calcule `line_amount = quantity * unit_price`

---

## 3) Donnees nettoyees (resultat ETL)

Sortie:
- `data/sales_clean_etl_demo.csv`

Extrait:

```csv
order_ref,order_date,customer_email,product_name,category,quantity,unit_price,line_amount
A1001,2026-01-02,alice@example.com,Headphones,Audio,1,79.99,79.99
A1002,2026-01-02,bob@example.com,Wireless Mouse,IT,2,25.00,50.00
A1008,2026-01-07,hugo@example.com,USB-C Dock,IT,1,129.00,129.00
```

---

## 4) Modelisation analytique PostgreSQL (star schema)

Fichier:
- `data/analytics_sales_model_postgres.sql`

Principe:
- dimensions: `dim_date`, `dim_customer`, `dim_product`
- table de faits: `fact_sales`
- grain: 1 ligne = 1 produit dans 1 commande

```sql
CREATE TABLE analytics.fact_sales (
  sale_id BIGSERIAL PRIMARY KEY,
  order_ref TEXT NOT NULL,
  date_key INTEGER NOT NULL REFERENCES analytics.dim_date(date_key),
  customer_id INTEGER NOT NULL REFERENCES analytics.dim_customer(customer_id),
  product_id INTEGER NOT NULL REFERENCES analytics.dim_product(product_id),
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price > 0),
  line_amount NUMERIC(12,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
  UNIQUE (order_ref, date_key, customer_id, product_id, quantity, unit_price)
);
```

---

## 5) Chargement dans le modele (Load)

Fichier:
- `data/analytics_sales_load_postgres.sql`

Logique de chargement:
- `stg_sales_clean` (table de staging)
- `INSERT DISTINCT` dans les dimensions
- `INSERT` dans `fact_sales` (idempotent avec `ON CONFLICT DO NOTHING`)

Commande type:

```bash
psql -h 127.0.0.1 -p 5433 -U postgres -d shop -f data/analytics_sales_model_postgres.sql
psql -h 127.0.0.1 -p 5433 -U postgres -d shop -f data/analytics_sales_load_postgres.sql
```

---

## 6) Premiere analyse KPI sur le modele propre

Objectif:
- nombre de commandes
- chiffre d'affaires
- panier moyen

```sql
SELECT
  COUNT(DISTINCT order_ref) AS nb_orders,
  SUM(line_amount) AS revenue,
  ROUND(SUM(line_amount) / COUNT(DISTINCT order_ref), 2) AS avg_basket
FROM analytics.fact_sales;
```

---

## A retenir

- Sans nettoyage, les KPI sont faux.
- Sans modelisation, les requetes deviennent fragiles.
- ETL + modele analytique = base solide pour l'analyse SQL avancee (chapitre 13).

---

## A faire

- Exercice guide: `Exercices/12_analyse_de_donnees_etl.md`
- [Dépôt](https://github.com/Antoine07/db)
