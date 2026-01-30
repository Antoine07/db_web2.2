# Exercices MongoDB — 03. Collections & validation de schéma

Préparation :

```js
use("ny_restaurants");
```

## Exercice 1 — Comprendre les types

1) Affichez un document `restaurants`  
2) Identifiez le type de `_id` et `grades.date`

## Exercice 2 — Validation (concept)

Sur `restaurants`, proposez une validation minimale (liste) :
- champs obligatoires
- types attendus (string / number / date)

## Exercice 3 — (Optionnel) Appliquer une validation

Appliquez une validation `jsonSchema` sur `restaurants` (au moins `name`, `restaurant_id`, `borough`, `cuisine`, `address.zipcode`).
