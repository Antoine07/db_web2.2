# Exercices — 01. Installation et setup PostgreSQL

## Objectif

- Lancer PostgreSQL (Docker Compose)
- Importer la base “Boutique”
- Vérifier que tout fonctionne

## Exercice 1 — Vérification PostgreSQL

1) Lancez les conteneurs (depuis le dossier du TP) :
```bash
docker compose up -d
```

2) Connectez-vous en CLI :
```bash
docker compose exec postgres psql -U postgres -d shop
```

3) Exécutez :
```sql
SELECT version();
```

## Exercice 2 — Import du schéma + données

Option A (recommandé : script du TP) :
```bash
docker compose exec postgres psql -U postgres -d shop -v ON_ERROR_STOP=1 -f /shared/postgres/seed.sql
```

Option B (si vous avez `psql` en local) :
```bash
psql -h 127.0.0.1 -p 5433 -U postgres -d shop -v ON_ERROR_STOP=1 -f data/shop_schema_postgres.sql
psql -h 127.0.0.1 -p 5433 -U postgres -d shop -v ON_ERROR_STOP=1 -f data/shop_seed_postgres.sql
```

## Exercice 3 — Explorer la base

Dans `psql` :
```sql
\dt
\d customers
\d orders
\d order_items
```

Questions :
- Quelles colonnes sont `NOT NULL` ?
- Quelles colonnes sont `UNIQUE` ?
- Quelles tables existent dans `shop` ?

## Exercice 4 — Première requête

1) Affichez tous les produits (`id`, `name`, `price`)  
2) Affichez tous les clients (`id`, `email`)  
3) Affichez toutes les commandes (`id`, `status`, `ordered_at`)

## Exercice 5 — Sauver une session

Créez un fichier `mes_requetes.sql` (où vous voulez) qui contient :
- une commande `\c shop`
- 3 requêtes de votre choix
