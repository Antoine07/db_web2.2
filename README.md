# Cours SQL (PostgreSQL) — Slides Marp + Exercices

## Contenu

- Slides (Marp) : `slides/`
- Scripts SQL “fil rouge Boutique” : `data/`
- Demo ETL analyse de donnees (chap. 12) : `data/sales_raw_etl_demo.csv`, `scripts/etl_sales_clean.py`, `data/analytics_sales_model_postgres.sql`, `data/analytics_sales_load_postgres.sql`
- Exercices par chapitre : `Exercices/`
- TPs : `TPs/`
- (Nouveau) Cours MongoDB : `index_mongodb.md` + `slides/mongodb_*.md`
- (Nouveau) Cours MySQL (transcription) : `index_mysql.md` + `slides/mysql_*.md`

Cours en ligne :
- SQL (PostgreSQL) : https://antoine07.github.io/db_web2.2/
- MongoDB : https://antoine07.github.io/db_web2.2/mongodb_index.html
- MySQL : https://antoine07.github.io/db_web2.2/mysql_index.html

## Installation PostgreSQL (recommandé)

Pour le cours, on recommande **Docker Compose** (le même que pour les TPs) : tout le monde a le même setup, sans installation “native”.

## Démarrage rapide (base `shop`)

### Option A — Docker Compose (TPs) (recommandé)

Depuis `TPs/app-project-starter/` (ou votre copie du starter) :

```bash
docker compose up -d
docker compose exec postgres psql -U postgres -d shop -v ON_ERROR_STOP=1 -f /shared/postgres/seed.sql
docker compose exec postgres psql -U postgres -d shop
```

### Option C — Starter avec Notebook Python (chap. 12 ETL)

Depuis `starter/` :

```bash
docker compose up -d
```

Notebook :
- URL : `http://localhost:8889`
- Token : `sql-nosql`

Si vous avez deja des conteneurs/projets actifs, vous pouvez changer les ports sans modifier le YAML :

```bash
POSTGRES_PORT=55433 MONGODB_PORT=37017 ADMINER_PORT=18080 NOTEBOOK_PORT=18889 docker compose up -d
```

### Option B — Import depuis `data/` (si vous avez `psql` en local)

Si Postgres est exposé en `5433` (docker du TP) :

```bash
psql -h 127.0.0.1 -p 5433 -U postgres -d shop -v ON_ERROR_STOP=1 -f data/shop_schema_postgres.sql
psql -h 127.0.0.1 -p 5433 -U postgres -d shop -v ON_ERROR_STOP=1 -f data/shop_seed_postgres.sql
psql -h 127.0.0.1 -p 5433 -U postgres -d shop
```

Optionnel (partie JSON, PostgreSQL) :
```bash
psql -h 127.0.0.1 -p 5433 -U postgres -d shop -v ON_ERROR_STOP=1 -f data/shop_json_evolution_postgres.sql
```

## Démarrage rapide MongoDB (dataset `ny_restaurants`)

```bash
# depuis `starter/`
cd starter

# repartir proprement
docker compose down --volumes --remove-orphans
docker compose up -d

# récupérer les données (si besoin)
curl -L "https://raw.githubusercontent.com/mongodb/docs-assets/primer-dataset/primer-dataset.json" \
  -o shared/mongodb/restaurants.json

# seed (crée la base `ny_restaurants` + la collection `restaurants`)
docker compose exec -T mongodb mongoimport \
  --db ny_restaurants \
  --collection restaurants \
  --authenticationDatabase admin \
  --username root \
  --password root \
  --drop \
  --file /shared/restaurants.json

# Ouvrir directement la base (login: root / password: root)
docker compose exec mongodb mongosh "mongodb://root:root@localhost:27017/ny_restaurants?authSource=admin"
```

## Rendu des slides (Marp)

### Option 1 — VS Code

- Installer l’extension “Marp for VS Code”
- Ouvrir un fichier dans `slides/`
- Prévisualiser / exporter (PDF/HTML) depuis l’extension

### Option 2 — Marp CLI

Installer :
```bash
npm i -g @marp-team/marp-cli
```

Exporter un PDF :
```bash
marp slides/index.md --pdf -o exports/index.pdf
```

Exporter tous les decks :
```bash
mkdir -p exports
marp slides/*.md --pdf -o exports/
```

## Monorepo (pnpm) — Installer tout (TPs + corrections + exemples)

Prérequis : Node.js + Corepack.

```bash
corepack enable
corepack prepare pnpm@9.15.5 --activate

# depuis la racine du repo : installe toutes les dépendances des workspaces
pnpm i
```

### TP — Starter (API + client)

```bash
pnpm run tp:starter:dev
```

### TP — Correction (API + client)

```bash
pnpm run tp:correction:dev
```
