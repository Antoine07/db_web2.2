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

## Exercice 4 — Score moyen par borough (filtrer avec `$match`)

Calculez le score moyen des inspections par `borough`, puis ne gardez que les boroughs dont le score moyen est **supérieur ou égal à 15**.

Contraintes :
- uniquement `$unwind`, `$group`, `$match`
- uniquement `$avg` comme opérateur d’agrégation

Sortie attendue : `_id` (le borough) et `avgScore`.

Indice : `$unwind: "$grades"` → `$group` (avec `$avg: "$grades.score"`) → `$match` sur `avgScore`.

## Exercice 5 — Cuisines “à risque” (Manhattan) via score moyen

Pour `borough = "Manhattan"`, calculez le score moyen des inspections par `cuisine`, puis ne gardez que les cuisines dont le score moyen est **strictement supérieur à 20**.

Contraintes :
- uniquement `$unwind`, `$group`, `$match`
- uniquement `$avg` comme opérateur d’agrégation

Sortie attendue : `_id` (la cuisine) et `avgScore`.

Indice : `$match` est autorisé, mais ici on n’utilise pas `$sort` / `$limit` (ce n’est pas demandé).
