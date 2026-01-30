# Exercices MongoDB — 04. Fil rouge : Restaurants (modélisation)

Préparation :

```js
use("ny_restaurants");
```

## Exercice 1 — Lire le modèle actuel

1) Affichez un restaurant (champs clés)  
2) Affichez uniquement `address` + `grades` pour un restaurant

## Exercice 2 — Embedding vs references

Pour chacun des besoins suivants, choisissez **embedding** ou **references** et justifiez :

1) Afficher un restaurant + ses inspections (front)  
2) Ajouter une “fiche cuisine” (`cuisine` → description, origine) partagée par tous les restaurants  
3) Faire un reporting “top cuisines par borough”

## Exercice 3 — Mini refacto (papier)

Proposez une alternative de schéma pour les inspections :

- Version très “normalisée” : une collection `inspections` avec une référence vers `restaurant_id`
- Version très “dénormalisée” : tout garder/dupliquer dans `restaurants`
