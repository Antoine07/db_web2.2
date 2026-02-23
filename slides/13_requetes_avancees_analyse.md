---
marp: true
title: "SQL (PostgreSQL) — 13. Requêtes avancées d'analyse"
paginate: true
header: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
footer: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
---

# 13 — Requêtes avancées d'analyse
## 10 énoncés progressifs (PostgreSQL)

---

## Exercice 1

Sur les commandes `paid`, calcule le total par commande :
- `order_id`
- `ordered_at`
- `total_order`

Trie du plus grand total au plus petit.

---

## Exercice 2

Calcule le chiffre d'affaires journalier (`paid`) :
- `jour`
- `ca_jour`

Trie par date croissante.

---

## Exercice 3

À partir du CA journalier, ajoute un cumul :
- `jour`
- `ca_jour`
- `ca_cumule`

Indice : `SUM(...) OVER (ORDER BY jour)`.

---

## Exercice 4

Toujours sur le CA journalier, ajoute une moyenne mobile 3 jours :
- `jour`
- `ca_jour`
- `avg_3j`

Indice : `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW`.

---

## Exercice 5

Classe les clients par chiffre d'affaires payé :
- `customer_id`
- `email`
- `total_paid`
- `rang_ca`

Indice : `DENSE_RANK()`.

---

## Exercice 6

Trouve le meilleur client de chaque mois :
- `mois`
- `customer_id`
- `email`
- `total_paid`

Indice : `ROW_NUMBER() OVER (PARTITION BY mois ORDER BY total_paid DESC)`.

---

## Exercice 7

Calcule le CA par catégorie et sa part :
- `categorie`
- `ca`
- `part_ca_pct`

Indice : `SUM(ca) OVER ()`.

---

## Exercice 8

Segmente les clients en 4 groupes de valeur :
- `email`
- `total_paid`
- `quartile`

Indice : `NTILE(4) OVER (ORDER BY total_paid DESC)`.

---

## Exercice 9

Calcule le CA mensuel avec variation :
- `mois`
- `ca_mois`
- `ca_mois_prec`
- `delta_ca`
- `delta_pct`

Indice : `LAG(ca_mois)`.

---

## Exercice 10

Repère les commandes `paid` au-dessus de la moyenne de leur mois :
- `mois`
- `order_id`
- `total_order`
- `avg_mois`

Indice : fenêtre `AVG(total_order) OVER (PARTITION BY mois)`.

---

## Correction

- Exercices : `Exercices/13_requetes_avancees_analyse_postgres.md`
- Corrections : `corrections/13_requetes_avancees_analyse_postgres.md`

- [Dépôt](https://github.com/Antoine07/db)
