# Exercice guide — 12. Analyse de donnees (ETL + modelisation)

## Objectif

Mettre en place un mini pipeline analytique de bout en bout:
- nettoyer un CSV brut en Python
- charger les donnees propres dans un modele analytique PostgreSQL
- calculer des KPI simples

---

## Prerequis

- Docker Desktop lance
- Services du `starter` demarres
- Python Notebook disponible (service `notebook`)

---

## Etape 1 — Demarrer l'environnement

Depuis `starter/`:

```bash
docker compose up -d
```

Si conflit de ports:

```bash
POSTGRES_PORT=55433 MONGODB_PORT=37017 ADMINER_PORT=18080 NOTEBOOK_PORT=18889 docker compose up -d
```

Notebook:
- URL: `http://localhost:8889`
- token: `sql-nosql`

---

## Etape 2 — Executer l'ETL Python

Depuis la racine du projet:

```bash
python3 scripts/etl_sales_clean.py
```

Verifier le fichier de sortie:
- `data/sales_clean_etl_demo.csv`

Questions:
1. Combien de lignes sont lues au total ?
2. Combien de lignes sont conservees ?
3. Pourquoi certaines lignes sont-elles supprimees ?

---

## Etape 3 — Creer le modele analytique

```bash
psql -h 127.0.0.1 -p 5433 -U postgres -d shop -f data/analytics_sales_model_postgres.sql
```

Si vous avez override le port Postgres, adaptez `-p` (ex: `55433`).

A verifier:
- schema `analytics`
- tables `dim_date`, `dim_customer`, `dim_product`, `fact_sales`

---

## Etape 4 — Charger les donnees propres

```bash
psql -h 127.0.0.1 -p 5433 -U postgres -d shop -f data/analytics_sales_load_postgres.sql
```

Controle rapide:

```sql
SELECT COUNT(*) AS nb_lignes_faits
FROM analytics.fact_sales;
```

---

## Etape 5 — Requetes d'analyse

1) KPI global:

```sql
SELECT
  COUNT(DISTINCT order_ref) AS nb_orders,
  SUM(line_amount) AS revenue,
  ROUND(SUM(line_amount) / COUNT(DISTINCT order_ref), 2) AS avg_basket
FROM analytics.fact_sales;
```

2) Chiffre d'affaires par categorie:

```sql
SELECT dp.category, ROUND(SUM(fs.line_amount), 2) AS revenue
FROM analytics.fact_sales fs
JOIN analytics.dim_product dp ON dp.product_id = fs.product_id
GROUP BY dp.category
ORDER BY revenue DESC;
```

3) Top clients:

```sql
SELECT dc.customer_email, ROUND(SUM(fs.line_amount), 2) AS revenue
FROM analytics.fact_sales fs
JOIN analytics.dim_customer dc ON dc.customer_id = fs.customer_id
GROUP BY dc.customer_email
ORDER BY revenue DESC, dc.customer_email ASC
LIMIT 3;
```

---

## Etape 6 — Bonus Notebook (pandas)

Dans le notebook, lire le CSV propre:

```python
import pandas as pd

df = pd.read_csv("/home/jovyan/work/data/sales_clean_etl_demo.csv")
df.head()
```

Questions:
1. Quel est le CA total calcule avec `df["line_amount"].sum()` ?
2. Quelle categorie genere le plus de CA (`groupby`) ?
