---
marp: true
title: "SQL (PostgreSQL) — 06. Modèle relationnel"
paginate: true
header: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
footer: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
style: |
  details.answer > summary { cursor: pointer; font-weight: 700; }
  details.answer { margin-top: 12px; }
---

# 06 — Modèle relationnel
## PK, FK, contraintes, cardinalités

---

## Objectifs (ce chapitre)

- Savoir expliquer **PK** et **FK** précisément
- Comprendre les **contraintes** (qualité + cohérence)
- Lire un schéma : cardinalités 1–N, N–N (table de liaison)

---

## Schéma "Boutique" (rappel)

![Ouvrir le SVG](assets/boutique_uml.svg)

---

## PK (Primary Key) — définition

La **clé primaire (PK)** est l'identifiant officiel d'une ligne :
- **UNIQUE** : 2 lignes ne peuvent pas avoir la même PK
- **NOT NULL** : une PK ne peut pas être manquante
- **1 par table** (mais elle peut être **composée**)

---

## FK (Foreign Key) — définition

Une **clé étrangère (FK)** est une colonne (ou un groupe) qui **référence** une ligne d'une autre table :
- empêche de référencer un parent inexistant
- traduit une relation (souvent 1–N)
- `NOT NULL` sur la FK = relation obligatoire

---

## Contraintes (définition)

Une **contrainte** est une règle appliquée par PostgreSQL pour garantir :
- la **qualité** des données (`NOT NULL`, `UNIQUE`, `CHECK`)
- la **cohérence** entre tables (`FOREIGN KEY`)

---

## Contraintes nommées (pourquoi)

```sql
CONSTRAINT fk_orders_customer
  FOREIGN KEY (customer_id) REFERENCES customers(id)
```

Intérêt :
- maintenance plus simple (`DROP CONSTRAINT fk_orders_customer`)
- debug plus clair (nom dans les erreurs)
- conventions (`fk_...`, `chk_...`, `uq_...`)

---

## Cardinalités (lecture rapide)

- `customers` → `orders` : **1–N**
- `orders` → `order_items` : **1–N**
- `products` ↔ `orders` : **N–N** via `order_items`

---

## FK + suppression : le vrai sujet

Sans FK (ou sans règle), on peut créer des **orphelins** :
- une commande qui pointe vers un client supprimé
- une ligne de commande qui pointe vers une commande supprimée

La FK répond à : **"Que fait-on quand on supprime/modifie le parent ?"**

---

## `ON DELETE` : les 3 comportements utiles

- `RESTRICT` / `NO ACTION` (défaut) : **refuse** de supprimer si des enfants existent
- `CASCADE` : supprime automatiquement les enfants
- `SET NULL` : met la FK à `NULL` (si la colonne est nullable)

À choisir selon la règle métier + le besoin de traçabilité.

---

## Pourquoi ? (FK) — pourquoi PostgreSQL bloque une suppression ?

<details class="answer">
  <summary>Afficher la réponse</summary>

Pour éviter des données incohérentes : si on supprime le parent, les enfants auraient une FK qui ne pointe plus vers rien (**orphelins**).

Donc PostgreSQL te force à choisir :
- supprimer/traiter les enfants d'abord
- ou définir une règle (`CASCADE`, `SET NULL`, etc.)

</details>

---

## Exemple (fil rouge) — supprimer un client

Cas métier fréquent : **on ne veut pas perdre l'historique** (facturation, SAV, analytics).

```sql
DELETE FROM customers WHERE id = 1;
-- attendu : erreur (orders existent) => comportement RESTRICT
```

Décision métier typique :
- on **ne supprime pas** le client, on le "désactive" (ex: `deleted_at`, `is_active`)
- on conserve ses commandes (obligation légale / comptable)

---

## Pourquoi ? (métier) — pourquoi éviter `CASCADE` sur `customers → orders` ?

<details class="answer">
  <summary>Afficher la réponse</summary>

Parce que supprimer un client pourrait supprimer en cascade ses commandes, donc :
- perte d'historique (CA, panier moyen, etc.)
- problèmes de SAV/retours/litiges
- risques légaux/comptables

Dans beaucoup de cas, "supprimer" = **anonymiser** ou **désactiver**, pas effacer.

</details>

---

## Exemple (fil rouge) — supprimer une commande

Si on autorise la suppression d'une commande :
- soit on supprime d'abord ses lignes
- soit on active la cascade

```sql
BEGIN;
DELETE FROM orders WHERE id = 1; -- attendu : erreur si order_items existent
ROLLBACK;
```

En e-commerce réel : on préfère souvent **annuler** (`status='cancelled'`) plutôt que supprimer.

---

## `ON DELETE CASCADE` (orders → order_items)

Utile si une commande n'a aucun intérêt sans ses lignes (et qu'on autorise sa suppression).

```sql
ALTER TABLE order_items
  DROP CONSTRAINT fk_order_items_order;

ALTER TABLE order_items
  ADD CONSTRAINT fk_order_items_order
    FOREIGN KEY (order_id) REFERENCES orders(id)
    ON DELETE CASCADE;
```

---

## Exemple (fil rouge) — supprimer un produit / une catégorie

Supprimer un produit vendu pose des questions métier :
- historique (quoi a été vendu ? libellé ? TVA ?)
- SAV / retours / litiges

Dans le fil rouge, `order_items` référence `products(id)` :
- `RESTRICT` est souvent préférable
- alternative métier : **soft delete** du produit, et/ou snapshot des infos dans `order_items`


---

## PK composée (table de liaison)

Dans `order_items` :
- PK = `(order_id, product_id)`

Pourquoi ?
<details class="answer">
  <summary>Afficher la réponse</summary>

Pour empêcher le doublon "même produit dans la même commande" (sinon on aurait 2 lignes pour le même produit).

</details>


