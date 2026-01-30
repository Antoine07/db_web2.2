# Cours MongoDB — Plan du cours

Version en ligne : https://antoine07.github.io/db_web2.2/mongodb_index.html

## Slides (cours)

- Plan (source Marp) : [slides/mongodb_index.md](slides/mongodb_index.md)
- Plan (export HTML) : [docs/mongodb_index.html](docs/mongodb_index.html)
- Cours (dataset restaurants, “tout-en-un”, source Marp) : [slides/mongodb_restaurants_cours.md](slides/mongodb_restaurants_cours.md)

## Chapitres

1. Présentation des données (dataset `restaurants.json`) — [Slides](slides/mongodb_01_installation_mongodb.md) · [HTML](docs/mongodb_01_installation_mongodb.html)
2. Requêtes de base : `find` — [Slides](slides/mongodb_02_modele_document_bson.md) · [HTML](docs/mongodb_02_modele_document_bson.html)
3. Agrégation (1) : bases — [Slides](slides/mongodb_08_aggregation_pipeline.md) · [HTML](docs/mongodb_08_aggregation_pipeline.html)
4. Agrégation (2) : pipes avancés — [Slides](slides/mongodb_09_indexation_performance.md) · [HTML](docs/mongodb_09_indexation_performance.html)
5. `$lookup` (join entre collections) — [Slides](slides/mongodb_06_relations_lookup.md) · [HTML](docs/mongodb_06_relations_lookup.html)
6. Validation : JSON Schema (MongoDB) — [Slides](slides/mongodb_03_collections_validation_schema.md) · [HTML](docs/mongodb_03_collections_validation_schema.html)
7. TypeScript + MongoDB : valider côté code et côté DB — [Slides](slides/mongodb_11_typescript_mongodb_validation.md) · [HTML](docs/mongodb_11_typescript_mongodb_validation.html)

## Exercices

- Import + vérifications : [Exercices/mongodb_01_installation_et_setup.md](Exercices/mongodb_01_installation_et_setup.md)
- `find` (8 exercices) : [Exercices/mongodb_02_modele_document_bson.md](Exercices/mongodb_02_modele_document_bson.md)
- Agrégation (bases) : [Exercices/mongodb_08_aggregation_pipeline.md](Exercices/mongodb_08_aggregation_pipeline.md)
- Agrégation (pipes avancés) : [Exercices/mongodb_09_aggregation_pipes_avances.md](Exercices/mongodb_09_aggregation_pipes_avances.md)
- `$lookup` : [Exercices/mongodb_06_relations_lookup.md](Exercices/mongodb_06_relations_lookup.md)
- Validation JSON Schema : [Exercices/mongodb_03_collections_validation_schema.md](Exercices/mongodb_03_collections_validation_schema.md)
- Exemple TypeScript (validation côté code + DB) : `examples/mongodb-ts-validation/`

## Corrections

- Import + vérifications : [corrections/mongodb_01_installation_et_setup.md](corrections/mongodb_01_installation_et_setup.md)
- `find` : [corrections/mongodb_02_modele_document_bson.md](corrections/mongodb_02_modele_document_bson.md)
- Agrégation (bases) : [corrections/mongodb_08_aggregation_pipeline.md](corrections/mongodb_08_aggregation_pipeline.md)
- Agrégation (pipes avancés) : [corrections/mongodb_09_aggregation_pipes_avances.md](corrections/mongodb_09_aggregation_pipes_avances.md)
- `$lookup` : [corrections/mongodb_06_relations_lookup.md](corrections/mongodb_06_relations_lookup.md)
- Validation JSON Schema : [corrections/mongodb_03_collections_validation_schema.md](corrections/mongodb_03_collections_validation_schema.md)

## Données (fil rouge)

- Dataset MongoDB (NY restaurants) : `https://raw.githubusercontent.com/mongodb/docs-assets/primer-dataset/primer-dataset.json`
- Fichier local (après téléchargement) : `starter/shared/mongodb/restaurants.json`
