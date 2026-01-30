---
marp: true
title: "SQL (PostgreSQL) — 09. Normalisation (formes normales)"
paginate: true
header: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
footer: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
---

# 09 — Normalisation
## 1NF, 2NF, 3NF (avec exemples)

---

## Pourquoi normaliser ?

Éviter :
- doublons (email recopié partout)
- incohérences (2 prix différents pour le même produit)
- anomalies (update/insert/delete)

---

## Pourquoi normaliser ? (le vrai problème)

Quand on **ne normalise pas**, on a 3 types de bugs classiques en base :

###  Doublons

```text
client@email.com répété dans 200 lignes
```

➡️ plus de place disque
➡️ plus lent
➡️ impossible de garantir que c’est toujours la même valeur

---

###  Incohérences

```text
Produit A = 10€
Produit A = 12€
```

➡️ lequel est le bon ?
➡️ la base **ne sait pas**

---

###  Anomalies

#### Anomalie d’UPDATE

- changer un prix → oublié dans certaines lignes

#### Anomalie d’INSERT

- impossible d’ajouter un produit sans commande

#### Anomalie de DELETE

- supprimer une commande → perte d’infos client

👉 **La normalisation sert à éviter ces situations.**

---

## 2️⃣ Exemple “sale” (dénormalisé)

Table unique :

```text
sales_flat
```

| order_id | customer_email                  | customer_name | items    | total |
| -------- | ------------------------------- | ------------- | -------- | ----- |
| 1        | [a@mail.com](mailto:a@mail.com) | Alice         | [P1, P2] | 40    |

---

### Pourquoi c’est mauvais ?

#### ❌ `items` contient une liste

```text
[P1, P2]
```

➡️ impossible à indexer correctement
➡️ impossible à joindre (`JOIN`)
➡️ violation directe de la 1NF

---

#### ❌ Infos client répétées

- même email sur plusieurs commandes
- risque d’incohérence

---

#### ❌ Produits non maîtrisés

- pas de table `products`
- pas de prix officiel
- pas de contraintes

---

##  1NF — First Normal Form

### Idée clé (simple)

> **Une colonne = une valeur atomique**

---

### ❌ Avant (pas 1NF)

```text
items = [P1, P2, P3]
```

---

###  Après (1NF)

```text
orders
-------
id | customer_id | total

order_items
-----------
order_id | product_id
```

Chaque produit est :

- sur **une ligne**
- dans **une seule cellule**

👉 Maintenant :

- on peut faire des `JOIN`
- on peut compter
- on peut indexer

---

## 4️⃣ 2NF — Second Normal Form

👉 Elle concerne **uniquement les clés composées**.

---

### Exemple

```text
order_items
-----------
(order_id, product_id)  ← clé composée
product_name
quantity
```

---

### Problème

- `product_name` dépend de **product_id**
- pas de `order_id`

👉 Dépendance **partielle** à la clé

---

### ❌ Violation 2NF

```text
(order_id, product_id) → product_name
```

---

### ✅ Solution 2NF

Séparer :

```text
products
--------
product_id | product_name

order_items
-----------
order_id | product_id | quantity
```

👉 Chaque colonne dépend **de toute la clé**

---

### Phrase clé (examen)

> **Si une colonne dépend d’une partie de la clé composite, elle n’est pas à sa place.**

---

##  3NF — Third Normal Form

La plus subtile.

---

### Idée clé

> **Une colonne non-clé ne doit dépendre d’aucune autre colonne non-clé**

---

### Exemple problématique

```text
customers
---------
id | city | postal_code
```

Sachant que :

```text
postal_code → city
```

---

### Problème (dépendance transitive)

```text
id → postal_code → city
```

➡️ `city` dépend **indirectement** de `id`

---

### ❌ Violation 3NF

- changer le nom d’une ville
- des centaines de lignes à corriger

---

### ✅ Solution 3NF

```text
postal_codes
------------
postal_code | city

customers
---------
id | postal_code
```

---

## 6️⃣ Comment lire la décomposition finale

La décomposition montre que :

- chaque **entité métier** a sa table
- chaque table a une **responsabilité unique**
- les relations passent par des **FK**

👉 Résultat :

- données cohérentes
- contraintes applicables
- requêtes fiables

---

## 7️⃣ Résumé ultra-synthèse (à mémoriser)

| Forme normale | Question à se poser                            |
| ------------- | ---------------------------------------------- |
| 1NF           | Ai-je une seule valeur par cellule ?           |
| 2NF           | Mes colonnes dépendent-elles de toute la clé ? |
| 3NF           | Une colonne dépend-elle d’une autre colonne ?  |

---

## Décomposition (vue d'ensemble)

![Ouvrir le SVG](assets/normalization_decomposition.svg)
