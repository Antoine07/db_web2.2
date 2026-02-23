# Exercices — 13. Requêtes avancées d'analyse (PostgreSQL)

## Préparation

```sql
\c shop
```

## Exercice 1 — Total par commande payée

Retournez pour chaque commande `paid` :
- `order_id`
- `ordered_at`
- `total_order = SUM(quantity * unit_price)`

Trie : total décroissant.

## Exercice 2 — CA journalier

Calculez le chiffre d'affaires par jour (`paid`) :
- `jour`
- `ca_jour`

Trie : jour croissant.

## Exercice 3 — CA cumulé

À partir du CA journalier, ajoutez :
- `ca_cumule`

Indice : `SUM(ca_jour) OVER (ORDER BY jour)`.

## Exercice 4 — Moyenne mobile 3 jours

Toujours sur le CA journalier, ajoutez :
- `avg_3j`

Indice : `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW`.

## Exercice 5 — Classement clients (CA payé)

Retournez :
- `customer_id`
- `email`
- `total_paid`
- `rang_ca`

Indice : `DENSE_RANK()`.

## Exercice 6 — Meilleur client de chaque mois

Retournez :
- `mois`
- `customer_id`
- `email`
- `total_paid`

Un seul client par mois.

Indice : `ROW_NUMBER() OVER (PARTITION BY mois ORDER BY total_paid DESC)`.

## Exercice 7 — Part de CA par catégorie

Retournez :
- `categorie`
- `ca`
- `part_ca_pct`

Indice : `SUM(ca) OVER ()`.

## Exercice 8 — Segmentation clients en quartiles

Retournez :
- `email`
- `total_paid`
- `quartile`

Indice : `NTILE(4)`.

## Exercice 9 — Variation mensuelle du CA

Retournez :
- `mois`
- `ca_mois`
- `ca_mois_prec`
- `delta_ca`
- `delta_pct`

Indice : `LAG(ca_mois)`.

## Exercice 10 — Commandes au-dessus de la moyenne du mois

Retournez les commandes `paid` dont le total est strictement supérieur à la moyenne de leur mois :
- `mois`
- `order_id`
- `total_order`
- `avg_mois`
