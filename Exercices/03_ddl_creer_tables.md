# Exercices — 03. DDL : créer des tables

## Préparation

Dans `psql` :
```sql
CREATE DATABASE shop_demo;
```

Puis :
```sql
\c shop_demo
```

## Exercice 1 — Table simple

Créez une table `notes` :
- `id` auto-incrémentée (Postgres : `GENERATED ... AS IDENTITY`, ou `SERIAL`)
- `title` obligatoire
- `content` optionnel
- `created_at` avec `DEFAULT CURRENT_TIMESTAMP`

## Exercice 2 — Contraintes de qualité

Sur une table `users` :
- `email` obligatoire et unique
- `age` obligatoire et >= 0 (avec `CHECK`)

Ajoutez 2 inserts "OK" et 2 inserts qui doivent échouer.

## Exercice 3 — Contraintes nommées

Créez une table `users` avec des contraintes **nommées** :
- `email` obligatoire et unique (nommez la contrainte `uq_users_email`)
- `age` obligatoire et `age >= 0` (nommez la contrainte `chk_users_age`)

## Exercice 4 — Lire un schéma

Utilisez :
```sql
\d+ users
```

Questions :
- Où voit-on le nom de la contrainte ?
- Comment sait-on que `email` est unique ?
