# Exercices MongoDB — 02. Requêtes `find` (8 exercices)

Préparation :

```js
use("ny_restaurants");
```

## Exercice 1 — Projection

Listez 20 restaurants avec uniquement :
- `name`, `borough`, `cuisine`

Sans `_id`.

## Exercice 2 — Filtres simples (AND)

Trouvez 10 restaurants à :
- `borough = "Manhattan"`
- `cuisine = "Italian"`

Affichez seulement `name` + `address.zipcode` (sans `_id`).

## Exercice 3 — `IN` (`$in`)

Trouvez les restaurants dont `borough` est dans :
- `["Bronx", "Queens", "Brooklyn"]`

Bonus : affichez le nombre de résultats avec `countDocuments`.

## Exercice 4 — Regex (recherche “contient”)

Trouvez les restaurants dont le `name` contient `pizza` (insensible à la casse).
Affichez `name`, `borough`, `cuisine` (sans `_id`).

## Exercice 5 — Champs imbriqués (dot notation)

1) Trouvez les restaurants dont `address.zipcode` vaut `11215`  
2) Affichez seulement `name` + `address.street` + `address.zipcode` (sans `_id`)

## Exercice 6 — Tri + pagination

1) Prenez les restaurants de `Queens`  
2) Triez par `name` croissant  
3) Récupérez la “page 2” : `skip(10)` puis `limit(10)` (sans `_id`)

## Exercice 7 — Tableaux (match sur un champ)

Trouvez les restaurants qui ont déjà eu une note `C` (`grades.grade = "C"`).
Affichez `name`, `borough`, `cuisine` (sans `_id`).

## Exercice 8 — Tableaux : `$elemMatch` (même élément)

Trouvez les restaurants qui ont **au moins une inspection** avec :
- `grade = "A"`
- `score < 5`

Affichez `name`, `borough`, `cuisine` (sans `_id`).
