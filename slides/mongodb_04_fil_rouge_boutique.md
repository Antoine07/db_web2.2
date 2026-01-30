---
marp: true
title: "MongoDB — 04. Fil rouge : Restaurants (modélisation)"
paginate: true
header: "[← Index MongoDB](https://antoine07.github.io/db_web2.2/mongodb_index.html)"
footer: "[← Index MongoDB](https://antoine07.github.io/db_web2.2/mongodb_index.html)"
---

# MongoDB — 04

---

## Les collections

- `restaurants` (dataset "NYC restaurants")

Dataset : `restaurants.json` (cf. import via `mongoimport`)

---

## Exemple : restaurant

Un document `restaurant` contient déjà :
- une adresse (objet imbriqué)
- un historique d’inspections (tableau `grades`)

```js
use("ny");
db.restaurants.findOne({}, { name: 1, borough: 1, cuisine: 1, address: 1, grades: 1 });
```

---

## Embedding vs references

### Embedding (données incluses)

- + lecture simple (1 requête)
- - duplication (ex: nom du produit)

### References (ids)

- + données normalisées
- - parfois plusieurs requêtes ou `$lookup`

---

## Choix pour `grades` (inspections)

Le dataset choisit **embedding** :

- + lecture simple : un restaurant + ses inspections
- - le tableau peut grossir (attention aux documents "géants")

---

## Idées d’index "naturels"

Selon les requêtes fréquentes :
- `restaurant_id` (unique)
- `borough`, `cuisine` (filtres)
- `address.zipcode` (filtre)

---

## À retenir

- Le "bon" schéma MongoDB dépend des requêtes les plus fréquentes
- Modéliser = choisir où mettre la duplication (et pourquoi)

---

## Exercices

- Exercices : `Exercices/mongodb_04_fil_rouge_boutique.md`
