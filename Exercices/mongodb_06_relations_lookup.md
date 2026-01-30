# Exercices MongoDB — 06. Relations & `$lookup`

Préparation :

```js
use("ny_restaurants");
```

## Exercice 1 — Créer une collection “référencée”

Créez une collection `boroughs` (au moins 5 documents) :

- `_id`: le nom du borough (ex: `"Manhattan"`)
- un champ `area` (string)
- un champ `note` (string)

## Exercice 2 — Joindre `restaurants` → `boroughs`

Avec un pipeline `aggregate` + `$lookup` :

1) Prenez les restaurants de Manhattan  
2) Ajoutez le document `boroughs` correspondant  
3) Sortez `name` + `cuisine` + `borough_info.note`

## Exercice 3 — Joindre par cuisine (bonus)

1) Créez une collection `cuisines` avec `_id = cuisine` et `origin`/`tags`  
2) Faites un `$lookup` pour enrichir les restaurants (et limitez à 5 résultats)
