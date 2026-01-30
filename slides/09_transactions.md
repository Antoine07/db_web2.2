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

Idéal pour éviter un état “à moitié mis à jour”.

---

## Syntaxe minimale

```sql
BEGIN;

-- ... requêtes (INSERT/UPDATE/DELETE)

COMMIT;   -- valide
-- ROLLBACK; -- annule
```

---

## Savepoints (retour partiel)

```sql
BEGIN;

SAVEPOINT step1;
-- ... requêtes

ROLLBACK TO SAVEPOINT step1; -- annule uniquement depuis step1
COMMIT;
```

---

## Exemple (à tester)

```sql
SELECT name FROM products;

DO $$
BEGIN
  BEGIN
    DELETE FROM products where id = 1; -- référence restrict 
    UPDATE products
    SET name = 'bar'
    WHERE id = 1;

  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'Erreur FK attrapée';
  END;
END $$;

SELECT name FROM products;
```

---

## Points à retenir (PostgreSQL)

- PostgreSQL est transactionnel par défaut
