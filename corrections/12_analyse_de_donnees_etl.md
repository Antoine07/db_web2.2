# Correction — 12. Analyse de donnees (ETL + modelisation)

## 1) Resultat ETL attendu

Commande:

```bash
python3 scripts/etl_sales_clean.py
```

Sortie attendue:
- `Rows read`: 15
- `Rows kept`: 8
- `Rows dropped`: 6
- `Rows duplicates`: 1

Causes de suppression:
- email invalide
- statut non `paid`
- date invalide
- quantite negative
- prix invalide

---

## 2) Modele analytique

Commande:

```bash
psql -h 127.0.0.1 -p 5433 -U postgres -d shop -f data/analytics_sales_model_postgres.sql
```

Si port custom, remplacez `5433` par votre port expose.

Tables attendues:
- `analytics.dim_date`
- `analytics.dim_customer`
- `analytics.dim_product`
- `analytics.fact_sales`

---

## 3) Chargement (Load)

Commande:

```bash
psql -h 127.0.0.1 -p 5433 -U postgres -d shop -f data/analytics_sales_load_postgres.sql
```

Verification:

```sql
SELECT COUNT(*) AS nb_lignes_faits
FROM analytics.fact_sales;
```

Resultat attendu:
- `nb_lignes_faits = 8`

---

## 4) Resultats des requetes

### KPI global

```sql
SELECT
  COUNT(DISTINCT order_ref) AS nb_orders,
  SUM(line_amount) AS revenue,
  ROUND(SUM(line_amount) / COUNT(DISTINCT order_ref), 2) AS avg_basket
FROM analytics.fact_sales;
```

Attendu:
- `nb_orders = 8`
- `revenue = 607.78`
- `avg_basket = 75.97`

### Chiffre d'affaires par categorie

```sql
SELECT dp.category, ROUND(SUM(fs.line_amount), 2) AS revenue
FROM analytics.fact_sales fs
JOIN analytics.dim_product dp ON dp.product_id = fs.product_id
GROUP BY dp.category
ORDER BY revenue DESC;
```

Attendu:
- `IT = 367.90`
- `Audio = 239.88`

### Top clients

```sql
SELECT dc.customer_email, ROUND(SUM(fs.line_amount), 2) AS revenue
FROM analytics.fact_sales fs
JOIN analytics.dim_customer dc ON dc.customer_id = fs.customer_id
GROUP BY dc.customer_email
ORDER BY revenue DESC, dc.customer_email ASC
LIMIT 3;
```

Attendu:
- `alice@example.com = 159.98`
- `hugo@example.com = 129.00`
- `chloe@example.com = 89.00`

---

## 5) Bonus pandas

```python
import pandas as pd

df = pd.read_csv("/home/jovyan/work/data/sales_clean_etl_demo.csv")
df["line_amount"].sum()
```

Attendu:
- `607.78`

```python
df.groupby("category", as_index=False)["line_amount"].sum().sort_values("line_amount", ascending=False)
```

Attendu:
- `IT` puis `Audio`
