# Exercices MongoDB — 07. Écritures : updates + upsert

Préparation :

```js
use("ny_restaurants");
```

## Exercice 1 — `insertOne`

Insérez un nouveau restaurant :
- `restaurant_id`: `demo-001`
- `name`: `Demo Restaurant`
- `borough`: `Manhattan`
- `cuisine`: `French`
- `address.zipcode`: `10001`

## Exercice 2 — `$set` et `$inc`

1) Mettez `cuisine` à `"French (Modern)"`  
2) Ajoutez un champ `visits` et incrémentez-le de `+1`

## Exercice 3 — Upsert

Créez (ou mettez à jour) un restaurant `demo-002` avec `upsert: true`.

## Exercice 4 — Delete

Supprimez le restaurant `demo-001`.
