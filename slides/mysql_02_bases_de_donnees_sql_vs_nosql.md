---
marp: true
title: "SQL (MySQL) — 02. Bases de données (SQL vs NoSQL)"
paginate: true
header: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
footer: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
---

# 02 — Bases de données

> Variante MySQL transcrite depuis le parcours PostgreSQL (adapter les syntaxes spécifiques).


---

## C'est quoi une base de données ?

- Un système pour **stocker** des données
- Les retrouver via des **requêtes**
- Gérer la **concurrence** (plusieurs utilisateurs)
- Garantir des **règles** (contraintes) et/ou de la **cohérence**

---

## Contexte historique (SQL et SGBD)

---

## Origine du SQL (années 1970)

- Années 1970 : IBM développe le **modèle relationnel** (Edgar F. Codd)
- Objectif :
  → représenter les données sous forme de **tables**
  → interroger les données avec un **langage déclaratif**
- SQL = **Structured Query Language**
- Normalisé progressivement (ANSI / ISO)

---

👉 Le relationnel devient la référence pour :

- gestion de données métiers
- finance, ERP (entreprise Ressource Planning), ...
- systèmes transactionnels

---

## PostgreSQL : présentation ?

- Créé en **1996**
- Objectifs :
  - **fiable** (ACID, contraintes, intégrité)
  - **proche des standards SQL**
  - **extensible** (types, fonctions, index)
  - **open-source**

---

- Très utilisé dans le web :
  - APIs / backends (Node, Python, Java…)
  - produits data (BI, reporting)
  - applications CRUD

>PostgreSQL est un excellent SGBD pour apprendre le relationnel. Dans ce cours, c'est cette base de données que nous allons utiliser.

---

## Évolution et maturité

- Années 2000–2010 :

  - montée en charge des applications web
  - besoin de performance + fiabilité
- PostgreSQL apporte :
  - transactions + contraintes (FK, CHECK…)
  - index avancés
  - types riches (dont `JSONB`)

---

Aujourd'hui :

- PostgreSQL est un **SGBD relationnel complet**
- toujours très utilisé en production

---

## Apparition du NoSQL (années 2010)

- Nouveaux besoins :

  - très gros volumes de données (`big data`)
  - haute disponibilité
  - schéma flexible ou évolutif, contrairement aux bases relationnelles qui reposent sur un schéma fortement structuré
- Apparition du terme **NoSQL**
- Pas un remplacement du SQL, mais :

  - une **autre famille de solutions**

---

## NoSQL remarque importante

- Avec le NoSQL, la base n'impose pas de schéma strict : c'est le code de l'application qui définit et fait évoluer la structure des données.

*En vanilla code (sans ORM ni framework), la structure des données est entièrement définie par le code applicatif.*

---

>SQL et NoSQL peuvent coexister, selon le problème à résoudre dans une même application.

---

## PostgreSQL pour le cours

- SQL = **base fondamentale** de la modélisation des données
- PostgreSQL = excellent pour comprendre - nous allons aborder tout ça durant le cours 

  - tables
  - relations
  - jointures
  - contraintes
  - logique transactionnelle

---

> Comprendre le relationnel est indispensable,
> même si l'on utilise ensuite du NoSQL.

---


## SGBD

*En anglais `DBMS` signifie Database Management System*

Un **SGBD** (Système de Gestion de Base de Données) fournit :
- stockage persistant + index
- requêtes (langage, API)
- transactions et garanties de cohérence (selon le modèle)
- sécurité (droits)
- sauvegarde/restauration

---

>Exemples de SGDB ou  DBMS en anglais : PostgreSQL, SQLite, MongoDB, Redis…

---

## SQL relationnel

- Données en **tables** (colonnes typées)
- Relations entre tables via **PK/FK** (clé primaire et secondaire)
- Requêtes déclaratives : "ce que je veux extraire des tables"
- Forte cohérence et contraintes pour les données, selon configuration (moteur).

---

## NoSQL

"NoSQL" = famille de bases **non relationnelles** (plusieurs modèles) :
- **Document** (MongoDB)
- **Key-value** (Redis)
- **Column-family** (Cassandra)
- **Graph** (Neo4j)

---


## Exemple : même besoin, deux approches

Commande + lignes de commande :
- SQL : `orders` + `order_items`
- NoSQL (document) : un document "order" avec un tableau `items`

---

![Ouvrir le SVG](assets/sql_vs_nosql_order.svg)
