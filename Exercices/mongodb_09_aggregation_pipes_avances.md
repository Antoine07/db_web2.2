# Exercices MongoDB — Agrégation (2) : pipes avancés

Préparation :

```js
use("ny_restaurants");
```

## Exercice 1 — Top restaurants (min 3 inspections)

Trouvez les 10 restaurants de Manhattan avec le meilleur `avgScore` (score moyen le plus faible),
en imposant au moins 3 inspections.

Indice : `$match` → `$unwind` → `$group` (avec `$avg` + `$sum`) → `$match` → `$sort` → `$limit`.

## Exercice 2 — Distribution des scores (`$bucket`)

Construisez une distribution des `grades.score` avec des buckets :
`[0,10)`, `[10,20)`, `[20,30)`, `[30,40)`, `[40,50)`, `[50,100)` et un bucket `100+`.

## Exercice 3 — 2 rapports en 1 (`$facet`)

Avec `$facet`, renvoyez :

1) `byBorough` : le nombre de restaurants par borough (tri décroissant)  
2) `topCuisinesInManhattan` : top 10 cuisines à Manhattan  

## Exercice 4 — Debug de pipeline (bonus)

Prenez votre pipeline de l’exercice 1 et :

1) Ajoutez un `$limit` très tôt pour itérer vite  
2) Ajoutez un `$project` tôt pour ne garder que les champs utiles  
