---
marp: true
title: "MongoDB — 10. Bonnes pratiques (modèle, sécurité, prod)"
paginate: true
header: "[← Index MongoDB](https://antoine07.github.io/db_web2.2/mongodb_index.html)"
footer: "[← Index MongoDB](https://antoine07.github.io/db_web2.2/mongodb_index.html)"
---

# MongoDB — 10
## Bonnes pratiques (modèle, sécurité, prod)

---

## Modélisation

- Partir des requêtes réelles
- Éviter les documents "géants"
- Duplication contrôlée (ex: historique `grades[]` vs collection séparée)

---

## Migrations / versioning

- Ajouter un champ `schema_version`
- Scripts de migration (idempotents)
- Backfill progressif si besoin

---

## Requêtes

- Projeter les champs utiles (évite de "tout ramener")
- Toujours mettre un `$match` tôt dans les pipelines `aggregate`
- Se méfier des `$regex` non indexables (perf)

---

## Sécurité (minimum)

- Activer l'auth (en prod)
- Principe du moindre privilège (users/roles)
- Ne pas exposer le port 27017 publiquement

---

## Backups

- Atlas : backups gérés (selon offre)
- Sinon : stratégie dump/restore + rotation

---

## À retenir

- "Flexible" ne veut pas dire "sans règles"
- Le modèle de données est un choix produit (pas juste technique)

---

## Exercices

- Exercices : `Exercices/mongodb_10_bonnes_pratiques.md`
