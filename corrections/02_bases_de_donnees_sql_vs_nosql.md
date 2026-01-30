# Corrections — 02. Bases de données (SQL vs NoSQL)

## Exercice 1 — Définitions (exemples)

Énoncé : donnez une définition (1–2 phrases) + un exemple pour :
- base de données
- SGBD / DBMS
- transaction
- schéma

- **Base de données** : système permettant de stocker et interroger des données de manière persistante. Exemple : une base `shop`.
- **SGBD/DBMS** : logiciel qui gère la base (stockage, requêtes, droits, sauvegarde). Exemple : PostgreSQL, MongoDB.
- **Transaction** : ensemble d’opérations exécutées comme un tout (commit/rollback) selon le modèle. Exemple : créer une commande + ses lignes.
- **Schéma** : structure des données (tables/colonnes/contraintes en SQL ; “structure attendue” en NoSQL).

## Exercice 2 — SQL vs NoSQL (corrigé type)

Énoncé :
1) Complétez un tableau “SQL vs NoSQL” sur : schéma, jointures, cohérence, scalabilité  
2) Donnez 2 avantages et 2 limites pour chaque famille.

| Critère | SQL | NoSQL |
|---|---|---|
| Schéma | structuré (DDL) | souvent flexible |
| Jointures | natives | souvent évitées (ou spécifiques) |
| Cohérence | plutôt forte (ACID) | souvent plus flexible (BASE / eventual, selon DB) |
| Scalabilité | souvent verticale + réplication | souvent pensée horizontal |
| Cas typiques | back-office, reporting | cache, logs, contenus, événements |

## Exercice 3 — Choix (exemples)

Énoncé : pour chaque cas, choisir plutôt SQL ou NoSQL et justifier (2 arguments) :
- un dashboard de ventes (reporting)
- un cache de sessions utilisateur
- des logs d’événements très volumineux
- un back-office e-commerce (commandes, clients)

- Dashboard de ventes : **SQL** (agrégation, requêtes analytiques).
- Cache session : **NoSQL key-value** (Redis).
- Logs volumineux : **NoSQL** (document/column selon besoin).
- Back-office e-commerce : **SQL** (contraintes, intégrité, transactions).

## Exercice 4 — Modélisation (exemples)

Énoncé (même besoin : “une commande contient plusieurs produits”) :
1) Proposez une modélisation SQL (tables + clés)  
2) Proposez une modélisation NoSQL document (JSON)  
3) Donnez 1 avantage et 1 risque de l’approche document

1) SQL : `orders` + `order_items` (FK + table de liaison)  
2) NoSQL : document `order` avec `items[]`  
3) Avantage : lecture “tout en 1” ; risque : duplication et mises à jour complexes, documents qui grossissent.
