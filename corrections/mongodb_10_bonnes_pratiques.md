# Corrections MongoDB — 10. Bonnes pratiques

## Exercice 1 — Versionner le schéma (exemple)

1) Ajouter `schema_version: 1` à tous les nouveaux documents  
2) Écrire une migration idempotente `v1 -> v2` (batch)  
3) Pendant une transition, supporter lecture `v1` et `v2` côté code

## Exercice 2 — Sécurité minimum (exemple)

- Activer l’authentification
- Ne pas exposer MongoDB sur internet
- Restreindre par IP / VPC / firewall
- Users/roles minimaux par application
- Backups + chiffrement des secrets (URI)

## Exercice 3 — Modélisation (exemple)

1) Embedding : `grades[]` dans `restaurants` (lecture simple restaurant + inspections)  
2) References : collection `cuisines` référencée par `restaurants.cuisine` (fiche cuisine centralisée)

## Exercice 4 — Perf (bonus) (exemple)

- Mettre `$match` le plus tôt possible
- Projeter tôt (`$project`) pour réduire la taille des documents
- Indexer les champs filtrés/triés, et vérifier avec `explain`
