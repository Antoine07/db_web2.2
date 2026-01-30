# Exercices MongoDB — Agrégation (1) : bases

Préparation :

```js
use("ny_restaurants");
```

## Exercice 1 — Compter par borough

Calculez le nombre de restaurants par `borough`, trié du plus grand au plus petit.

Indice : `$group` + `$sort`.

## Exercice 2 — Top cuisines (Manhattan)

Pour `borough = "Manhattan"`, trouvez les 10 cuisines les plus représentées.

## Exercice 3 — Score moyen par cuisine (bonus)

Pour `borough = "Manhattan"`, calculez le `score` moyen des inspections par cuisine.

Indice : `$unwind: "$grades"` puis `$group` avec `$avg`.
