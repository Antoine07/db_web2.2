---
marp: true
title: "SQL (PostgreSQL) — 04. Fil rouge : Boutique"
paginate: true
header: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
footer: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
---

# 04 — Fil rouge : "Boutique"

---

## Objectif

- Avoir un exemple concret qui revient tout le temps
- Savoir dire : "où est la vérité ?" (clients, commandes, produits…)

---

## Schéma UML 


![Ouvrir le SVG](https://antoine07.github.io/db_web2.2/assets/boutique_uml.svg)

---

## Tables (rôle)

- `customers` : informations client (référence)
- `orders` : événement "commande" (qui, quand, statut)
- `order_items` : lignes de commande (quoi, combien, prix au moment)
- `products` : catalogue (prix actuel, stock)
- `categories` : catégorie de produit

---

## Pourquoi `unit_price` est dans `order_items` ?

Parce qu'on veut garder le **prix au moment de l'achat** (même si le prix du catalogue change).

---

## Import 

```bash
docker compose exec postgres psql -U postgres -d shop -v ON_ERROR_STOP=1 -f /shared/postgres/seed.sql
docker compose exec postgres psql -U postgres -d shop
```

---

## À faire (exercices)

- Exercices : `Exercices/04_fil_rouge_boutique.md`
- [Dépôt](https://github.com/Antoine07/db)
