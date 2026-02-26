---
marp: true
title: "SQL (PostgreSQL) — 09. Transactions"
paginate: true
header: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
footer: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
---

# 09 — Transactions
## Sécuriser des opérations multi-étapes

---

## Pourquoi une transaction ?

Une transaction regroupe plusieurs requêtes en **une seule opération logique** :
- soit **tout passe** (`COMMIT`)
- soit **on annule tout** (`ROLLBACK`)

Idéal pour éviter un état "à moitié mis à jour".

---

## ACID (l'idée derrière)

- **A**tomicité : tout ou rien
- **C**ohérence : les contraintes restent vraies (FK, CHECK, NOT NULL…)
- **I**solation : ta transaction voit une vue "cohérente" malgré la concurrence
- **D**urabilité : après `COMMIT`, c'est persisté

---

## Autocommit vs transaction explicite

Sans `BEGIN`, PostgreSQL exécute chaque requête dans sa **propre** transaction implicite :

- `INSERT ...;` → validé immédiatement
- si la requête suivante échoue → **la précédente reste** (état partiellement mis à jour)

Dès qu’on a "plusieurs étapes" qui doivent réussir ensemble → `BEGIN ... COMMIT`.

---

## Syntaxe minimale (SQL)

```sql
BEGIN;

-- ... requêtes (INSERT/UPDATE/DELETE)

COMMIT;   -- valide
-- ROLLBACK; -- annule
```

---

# Exemple simple

```sql
BEGIN;

-- On insère une première ligne.
INSERT INTO test_data (value) VALUES ('première valeur');

-- On insère une deuxième ligne mais on change d’avis.
SAVEPOINT avant_deuxieme;

INSERT INTO test_data (value) VALUES ('deuxième valeur');

-- Finalement, on regrette la deuxième insertion et on annule à partir du savepoint.
ROLLBACK TO SAVEPOINT avant_deuxieme;

-- On valide ce qui reste (donc seule la première insertion est gardée).
COMMIT;
```


---

## Savepoint : garder le "core", annuler un "bonus"

Ex : on crée une commande + lignes (core), puis on essaye d'ajouter une ligne "bonus".

```sql
BEGIN;

-- core : commande + lignes OK
-- ...

SAVEPOINT bonus;

-- bonus : ligne facultative (peut échouer)
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (123, 999999, 1, 0); -- exemple d'échec

-- si échec :
ROLLBACK TO SAVEPOINT bonus;

COMMIT;
```

---

## Pourquoi c'est indispensable ?

Cas classique :
- créer une commande (`orders`)
- ajouter des lignes (`order_items`)
- décrémenter le stock (`products.stock`)

Si une étape échoue, on ne veut **rien** garder.


## Concurrence : le piège du "lost update"

Deux utilisateurs achètent en même temps le dernier produit :
- chacun lit `stock = 1`
- chacun fait `stock = stock - 1`
→ on peut finir avec `stock = -1` (ou "vendu deux fois")

Solution classique : verrouiller la ligne pendant la transaction.

---

## Exemple de transaction

`Examples/transaction_python.py` 
[Dépôt](https://github.com/Antoine07/db))

---

## Isolation : niveaux (à connaître)

- `READ COMMITTED` (défaut) : chaque requête voit l'état validé au moment où elle démarre
- `REPEATABLE READ` : "snapshot" stable pendant toute la transaction
- `SERIALIZABLE` : le plus strict (peut lever des erreurs de sérialisation → à retry côté app)

Dans un projet web, on commence souvent avec `READ COMMITTED` + bons verrous / contraintes.

---

## Points à retenir 

- Pour du multi-étapes : `BEGIN` / `COMMIT` / `ROLLBACK`
- `SAVEPOINT` = rollback partiel (utile pour des "bonus")
- Concurrence : penser verrous (`FOR UPDATE`) + contraintes
- Pour la partie "NoSQL" (JSON/JSONB), voir le chapitre 10

---

## Example en Node.js

- Exemple en Node.js d'utilisation de transaction
- `Examples/transaction.js`

[Dépôt](https://github.com/Antoine07/db))