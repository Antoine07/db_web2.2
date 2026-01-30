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

## Exemple : pourquoi c'est indispensable (fil rouge `shop`)

Cas classique :
- créer une commande (`orders`)
- ajouter des lignes (`order_items`)
- décrémenter le stock (`products.stock`)

Si une étape échoue, on ne veut **rien** garder.

---

## Exemple SQL : créer une commande "atomique"

```sql
BEGIN;

WITH new_order AS (
  INSERT INTO orders (customer_id, status, ordered_at)
  VALUES (1, 'pending', NOW())
  RETURNING id
),
items AS (
  SELECT *
  FROM (
    VALUES
      (1, 2, 14.00::numeric), -- product_id, quantity, unit_price
      (2, 1, 65.00::numeric)
  ) AS v(product_id, quantity, unit_price)
),
inserted_items AS (
  INSERT INTO order_items (order_id, product_id, quantity, unit_price)
  SELECT new_order.id, items.product_id, items.quantity, items.unit_price
  FROM new_order
  CROSS JOIN items
  RETURNING product_id, quantity
)
UPDATE products p
SET stock = p.stock - inserted_items.quantity
FROM inserted_items
WHERE p.id = inserted_items.product_id;

COMMIT;
```

---

## Démonstration d'échec : rollback

Si une des requêtes échoue (ex : `product_id` inexistant → FK), alors :
- la transaction passe en état "erreur"
- on doit faire un `ROLLBACK` (sinon on ne peut plus rien exécuter dans cette transaction)

```sql
BEGIN;

WITH new_order AS (
  INSERT INTO orders (customer_id, status, ordered_at)
  VALUES (1, 'pending', NOW())
  RETURNING id
)
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT new_order.id, 999999, 1, 9.99
FROM new_order;

-- la requête ci-dessus échoue => ROLLBACK obligatoire
ROLLBACK;
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

## Concurrence : le piège du "lost update"

Deux utilisateurs achètent en même temps le dernier produit :
- chacun lit `stock = 1`
- chacun fait `stock = stock - 1`
→ on peut finir avec `stock = -1` (ou "vendu deux fois")

Solution classique : verrouiller la ligne pendant la transaction.

---

## `SELECT ... FOR UPDATE` (verrouiller une ligne)

```sql
BEGIN;

-- verrouille la ligne produit jusqu'au COMMIT/ROLLBACK
SELECT stock
FROM products
WHERE id = 10
FOR UPDATE;

-- ensuite seulement, on modifie
UPDATE products
SET stock = stock - 1
WHERE id = 10 AND stock > 0;

COMMIT;
```

Remarque : le `WHERE stock > 0` est un "garde-fou" utile.

---

## Isolation : niveaux (à connaître)

- `READ COMMITTED` (défaut) : chaque requête voit l'état validé au moment où elle démarre
- `REPEATABLE READ` : "snapshot" stable pendant toute la transaction
- `SERIALIZABLE` : le plus strict (peut lever des erreurs de sérialisation → à retry côté app)

Dans un projet web, on commence souvent avec `READ COMMITTED` + bons verrous / contraintes.

---

## Exemple JS (Node.js) : transaction avec rollback (`pg`)

```js
import pg from "pg";
const { Pool } = pg;

const pool = new Pool({ connectionString: process.env.DATABASE_URL });

export async function createOrderAtomic({ customerId, items }) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const { rows } = await client.query(
      "INSERT INTO orders (customer_id, status, ordered_at) VALUES ($1, $2, NOW()) RETURNING id",
      [customerId, "pending"]
    );
    const orderId = rows[0].id;

    for (const item of items) {
      await client.query(
        "INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES ($1, $2, $3, $4)",
        [orderId, item.productId, item.quantity, item.unitPrice]
      );

      // garde-fou simple (et utile) contre le stock négatif
      const stockUpdate = await client.query(
        "UPDATE products SET stock = stock - $1 WHERE id = $2 AND stock >= $1",
        [item.quantity, item.productId]
      );
      if (stockUpdate.rowCount !== 1) {
        throw new Error("Insufficient stock");
      }
    }

    await client.query("COMMIT");
    return { orderId };
  } catch (err) {
    await client.query("ROLLBACK");
    throw err;
  } finally {
    client.release();
  }
}
```

---

## Exemple JS : verrouiller le stock (`FOR UPDATE`)

```js
export async function reserveStock({ productId, quantity }) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const { rows } = await client.query(
      "SELECT stock FROM products WHERE id = $1 FOR UPDATE",
      [productId]
    );
    if (rows.length === 0) throw new Error("Product not found");
    if (rows[0].stock < quantity) throw new Error("Insufficient stock");

    await client.query(
      "UPDATE products SET stock = stock - $1 WHERE id = $2",
      [quantity, productId]
    );

    await client.query("COMMIT");
  } catch (err) {
    await client.query("ROLLBACK");
    throw err;
  } finally {
    client.release();
  }
}
```

---

## Points à retenir (PostgreSQL)

- Pour du multi-étapes : `BEGIN` / `COMMIT` / `ROLLBACK`
- `SAVEPOINT` = rollback partiel (utile pour des "bonus")
- Concurrence : penser verrous (`FOR UPDATE`) + contraintes
- Pour la partie "NoSQL" (JSON/JSONB), voir le chapitre 10
