# Diagrammes (PlantUML)

Sources : `diagrams/*.puml`  
Rendus : `slides/assets/*.svg` (copiés aussi dans `docs/assets/` pour les exports HTML)

Rendu (nécessite réseau) :

```bash
./scripts/render_plantuml_svgs.sh
```

Diagrammes utilisés dans le cours :
- `diagrams/boutique_uml.puml` → `slides/assets/boutique_uml.svg` (chapitres 04, 06, 07)
- `diagrams/sql_execution_order.puml` → `slides/assets/sql_execution_order.svg` (chapitre 05)
- `diagrams/sql_vs_nosql_order.puml` → `slides/assets/sql_vs_nosql_order.svg` (chapitre 02)
- `diagrams/join_filter_where_vs_on.puml` → `slides/assets/join_filter_where_vs_on.svg` (chapitre 07)
- `diagrams/aggregation_levels.puml` → `slides/assets/aggregation_levels.svg` (chapitre 08)
- `diagrams/normalization_decomposition.puml` → `slides/assets/normalization_decomposition.svg` (chapitre 09)
