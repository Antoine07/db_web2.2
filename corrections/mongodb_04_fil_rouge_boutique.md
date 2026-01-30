# Corrections MongoDB — 04. Fil rouge : Restaurants (modélisation)

Préparation :

```js
use("ny_restaurants");
```

## Exercice 1 — Lire le modèle actuel

```js
db.restaurants.findOne({}, { name: 1, borough: 1, cuisine: 1, restaurant_id: 1 });
db.restaurants.findOne({}, { address: 1, grades: 1 });
```

## Exercice 2 — Embedding vs references (exemple de réponse)

1) Afficher restaurant + inspections (front) → embedding (`grades[]`)  
2) Fiche cuisine partagée → references (collection `cuisines`) + `$lookup` (ou duplication contrôlée)  
3) Top cuisines par borough → agrégation (pipeline) (pas besoin de references)

## Exercice 3 — Mini refacto (exemple)

- “Normalisée” : `inspections: { restaurant_id, date, grade, score }` (collection dédiée)
- “Dénormalisée” : tout dans `restaurants.grades[]` (lecture simple, mais tableau potentiellement volumineux)
