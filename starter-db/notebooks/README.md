# Notebooks (chapitre 12)

Le service `notebook` monte la racine du projet dans:
- `/home/jovyan/work`

Notebook dataviz robots (chapitre 14):
- `starter-db/notebooks/dataviz_robots.ipynb`
- dataset: `/home/jovyan/work/data/robots_missions.csv`

Exemple rapide dans un notebook:

```python
import pandas as pd

df = pd.read_csv("/home/jovyan/work/data/sales_clean_etl_demo.csv")
df.head()
```
