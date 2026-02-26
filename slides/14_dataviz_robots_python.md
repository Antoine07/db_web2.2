---
marp: true
title: "SQL + Python — 14. Dataviz robots"
paginate: true
header: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
footer: "[← Index des chapitres](https://antoine07.github.io/db_web2.2/#5)"
---

# 14 — Dataviz robots avec Python

---

## Positionnement du chapitre

- mise en DataFrame
- visualisation pour decision operationnelle

Objectif:
`question metier -> graphique lisible -> action`

---

## Fil rouge data robots

Cas:
flotte de robots logistiques en entrepot.

Questions:
- Pourquoi la productivite baisse de 14h a 16h ?
- Quelles zones causent le plus d'arrets ?
- Quel lien entre temperature, batterie et erreurs ?

---

# Nature et Structure des Données

Dataset de **logs opérationnels de robots logistiques**.

Chaque ligne représente :

> Une mission exécutée par un robot à un instant donné.

---

## Structure des données

### Dimensions

- **Temps** : `timestamp`
- **Robot** : `robot_id`, `robot_type`
- **Localisation** : `zone`
- **Processus** : `task_type`

---

### Indicateurs opérationnels

- Durée mission : `mission_duration_s`
- Temps d'arrêt : `downtime_s`
- Batterie : `battery_pct`
- Vitesse : `speed_mps`
- Température : `temperature_c`

---

### Fiabilité

- `error_code`
- `mission_status`
- `incident_label`

---

## Type de dataset

Logs événementiels horodatés
→ Exploitables en analyse temporelle, performance et fiabilité.

---

# Exploitation & KPI Potentiels

- Missions par heure / zone
- Durée moyenne par type de tâche
- Charge par robot

---

## Efficacité

Exemple de `KPI` (Key Performance Indicator)

```
efficiency = mission_duration / (mission_duration + downtime)
```

- Robots les plus performants
- Zones à friction

---

## Fiabilité

- Taux d'erreur global
- Taux d'incident par robot
- Corrélation batterie ↔ erreurs

---

##  Potentiel analytique

- Monitoring temps réel
- Détection d'anomalies
- Maintenance prédictive
- Optimisation des opérations

---

## Pipeline technique

`CSV/API -> Pandas -> Dataviz -> recommandations`

```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
```

Reglage style:

```python
# syle et context taille de la police
sns.set_theme(style="whitegrid", context="notebook")
# 11x6 → bon ratio pour affichage écran / 16:9, meilleure lisibilité
plt.rcParams["figure.figsize"] = (11, 6)
```

---

## Chargement des données - sans hypothèse

```python
from pathlib import Path

candidates = [
    Path('../../data/robots_missions.csv'),
]

# Sans hyptohèse
robots = pd.read_csv(candidates[0])
robots.head()
robots.info()
robots.columns
robots.dtypes
```


---
## Transformation des données `to_datetime`

```python
robots["timestamp"] = pd.to_datetime(robots["timestamp"], errors="coerce")
# errors="coerce" → transforme les erreurs en Nat 

robots["timestamp"].isna().sum() > 0 and "error"
```

---
## Exemple de transformation

```python

df = pd.DataFrame({
    "timestamp": ["2025-01-01", "invalid_date"]
})

df["timestamp"] = pd.to_datetime(df["timestamp"], errors="coerce")

print(df)
print(df.dtypes)

```

## Application `to_numeric`

> Transformez les valeurs en données numériques, même si Python infère déjà certaines valeurs tout seul.

---

## Solution 

```python
# Types numériques attendus
num_cols = ['mission_duration_s', 'downtime_s', 'battery_pct', 'speed_mps', 'temperature_c']
for c in num_cols:
    robots[c] = pd.to_numeric(df[c], errors='coerce')

```

---

## Chargement + qualite des donnees

```python
# Suppression des doublons
robots = robots.drop_duplicates()

# Conserver uniquement les missions dont la durée est strictement positive
robots = robots[robots["mission_duration_s"] > 0]

# Conserver uniquement les pourcentages de batterie valides (entre 0 et 100 inclus)
robots = robots[robots["battery_pct"].between(0, 100)]
```

---
## Renommage des colonnes 

```python
robots = robots.rename(columns={
    "timestamp": "event_ts",
    "robot_id" : "id",
    "robot_type": "type",
    "task_type": "task",
    "mission_duration_s": "duration",
    "downtime_s": "downtime",
    "battery_pct": "battery_level",
    "temperature_c": "temperature",
    "mission_status": "status",
    "incident_label": "incident",
    "error_code" : "error"
})
```

---

## Features utiles pour la dataviz

```python
robots["hour"] = robots["event_ts"].dt.hour
robots["day"] = robots["event_ts"].dt.date
robots["is_error"] = np.where(robots["error"].notna(), 1, 0)
# Pour ne pas diviser par zéro
robots = robots[robots["downtime"] > 0]
robots["efficiency"] = robots["duration"] / robots["downtime"]
```

---

# Astuce sélectionner uniquement certaine(s) colonne(s)

```python
robots[["id", "zone", "duration"]]
```

---

# Agrégation 

```python
df = pd.DataFrame({
    "product": ["A", "A", "B", "B", "B"],
    "quantity": [10, 15, 5, 8, 7]
})

df.groupby("product").agg(
    total =("quantity", "sum")
)
```

| produit | total_quantite |
|----------|---------------|
| A        | 25            |
| B        | 20            |

---
## Choisir le bon graphique

- Evolution temporelle -> `lineplot`
- Comparaison categories -> `barplot` / `boxplot`
- Distribution -> `histplot` / `kdeplot`
- Relation entre 2 variables -> `scatterplot`
- Correlation multi-variables -> `heatmap`


> un graphique = une question principale.


---

## Aggregats de base

Regrouper toutes les missions qui ont eu lieu à la même heure de la journée.

```python
kpi_hour = robots.groupby("hour", as_index=False).agg(
    missions=("id", "count"),
    error_rate=("is_error", "mean"),
    avg_battery=("battery_level", "mean"),
)
```

- missions → combien de missions ont été faites par heure
- error_rate → quel pourcentage de missions ont eu une erreur par heure
- avg_battery → niveau moyen de batterie par heure

---

## charge horaire de la flotte

```python
plt.plot(kpi_hour["hour"], kpi_hour["missions"], marker="o")
plt.title("Missions par heure")
plt.xlabel("Heure")
plt.ylabel("Nb missions")
plt.xticks(range(0, 24, 2))
plt.tight_layout()
plt.show()
```

> identifier creux/pics et les rapprocher du staffing.

---

## Rendu — Missions par heure

<img src="./assets/dataviz_robots/missions_by_hour.png" alt="Missions par heure" width="800" />

---

## distribution batterie

```python
sns.histplot(robots, x="battery_level", bins=20, kde=True, color="#1f77b4")
plt.title("Distribution du niveau de batterie")
plt.xlabel("Batterie (%)")
plt.ylabel("Frequence")
plt.tight_layout()
plt.show()
```

si masse sous 20%, risque d'arret operationnel.

---

`sns.histplot(robots, x="battery_level", bins=20, kde=True, color="#1f77b4")`

- robots → le DataFrame
- x="battery_level" → on analyse cette colonne
- bins=20 → on divise l'axe en 20 intervalles
- kde=True → ajoute une courbe lissée (tendance)
- color → couleur du graphique

---

## Rendu — Distribution batterie

<img src="./assets/dataviz_robots/battery_distribution.png" alt="Distribution batterie" width="800" />

---

>Un petit calcul pour savoir combien de batteries sont à 100%

```python
(robots["battery_level"] == 100).mean()
```

---

# Bilan

Les graphiques mettent en évidence une concentration non négligeable de batteries à 100 % (environ 23 % des missions).

Cela peut s'expliquer par :

- une politique de recharge systématique avant certaines plages horaires,
- un comportement spécifique lié à certains robots,
- ou certains types de tâches.

Il convient donc d'analyser la répartition :

- par heure,
- par zone,
- par robot,

afin de déterminer s'il s'agit d'un fonctionnement normal de l'exploitation ou d'un biais dans la collecte des données.

---

## Questions

- Les erreurs augmentent-elles lorsque la batterie est faible ?
- Les erreurs sont-elles indépendantes du niveau de batterie ?
- Le pic à 100 % a-t-il un impact sur les incidents ?

---

## Construire un graphique pour tester ces hypothèses

```python
# Création des tranches de batterie
robots["battery_bin"] = pd.cut(
    robots["battery_level"],
    bins=[0, 20, 50, 80, 100],
    labels=["0-20%", "20-50%", "50-80%", "80-100%"]
)
```

> Proposez un graphique permettant d'évaluer la relation entre le niveau de batterie et le taux d'erreur.

---

# La solution

```python
error_by_battery = (
    robots.groupby("battery_bin", as_index=False)["is_error"]
           .mean()
)

error_by_battery["is_error"] *= 100

plt.figure()
plt.bar(
    error_by_battery["battery_bin"].astype(str),
    error_by_battery["is_error"]
)
plt.xlabel("Tranche de batterie")
plt.ylabel("Taux d'erreur (%)")
plt.title("Taux d'erreur selon le niveau de batterie")
plt.show()
```

---

# Conclusion

Cela suggère que :
- une batterie faible augmente le risque d'erreur,
- l'autonomie devient un facteur opérationnel critique,
- la gestion de la recharge pourrait être optimisée.

---

## Présentation rapide du barplot (général)

Un **barplot** est un graphique en barres qui permet de comparer des valeurs entre différentes catégories.

- Chaque barre représente une catégorie (ex : une zone).
- La longueur de la barre correspond à une valeur (ex : un taux).
- Il sert à comparer visuellement des performances ou des indicateurs.

>C'est un outil simple, très lisible, idéal pour identifier des écarts.

---

## Exercice d'application

Analyser la performance opérationnelle par zone.

### Consigne

1. Calculez le taux d'erreur moyen par zone.
2. Triez les zones du taux d'erreur le plus élevé au plus faible.
3. Représentez le résultat sous forme de barplot horizontal.
4. Interprétez les zones les plus critiques.

- La variable `is_error` est binaire (0 = pas d'erreur, 1 = erreur).
- La moyenne d'une variable binaire correspond à un taux.

---

## Solution attendue

```python
zone_err = (
    robots.groupby("zone", as_index=False)["is_error"]
      .mean()
      .sort_values("is_error", ascending=False)
)

sns.barplot(data=zone_err, x="is_error", y="zone", palette="Reds_r")
plt.title("Taux d'erreur moyen par zone")
plt.xlabel("Taux d'erreur")
plt.ylabel("Zone")
plt.tight_layout()
plt.show()
```


---

## Rendu — Erreurs par zone

<img src="./assets/dataviz_robots/error_rate_by_zone.png" alt="Erreurs par zone" width="800" />

---

##  boxplot mesurer la distribution

>Le boxplot montre comment les valeurs sont distribuées et permet de comparer des groupes en un coup d'œil.

Pour chaque classe :
- La ligne au milieu → note médiane
- La boîte → 50 % des notes
- Les moustaches → dispersion globale
- Les points isolés → valeurs extrêmes

---

On définit un coefficient `1.5 × IQR`, c'est une règle conventionnelle pour définir la limite au-delà de laquelle une valeur est considérée comme atypique.

Il permet d'identifier les outliers sans être trop sensible aux petites variations normales de la distribution.

---

## Que fais cette fonction ?

```python
def upper_whisker(s):
    q1, q3 = s.quantile([0.25, 0.75])
    iqr = q3 - q1
    return q3 + 1.5 * iqr
```

>Testez cette fonction sur la `Série` suivante et concluez.

```python
s = pd.Series([10, 12, 13, 15, 18, 19, 20, 100])
```

---


# Exercice — Analyse de la variabilité du downtime 1/3

>Analyser la distribution du temps d'arrêt (`downtime`) selon le type de robot afin d'identifier :

- la performance typique,
- la variabilité,
- et d'éventuels comportements anormaux.

---

# Exercice — Analyse de la variabilité du downtime 2/3

1. Calculez la limite supérieure théorique (upper whisker) du downtime pour chaque type de robot en utilisant la règle : `Q3 + 1.5 X IQR`

2. Déterminez la limite maximale parmi les types afin de fixer un seuil d'affichage cohérent.

3. Construisez un boxplot du downtime par type de robot :
   - en masquant les outliers,
   - en limitant l'axe vertical au cœur de la distribution.

4. Interprétez :
   - la médiane,
   - la variabilité,
   - les différences entre types de robots.

---

## Rappels Analyse de la variabilité du downtime 3/3

- **La médiane** = ligne horizontale dans la boîte
- **La variabilité** = hauteur de la boîte (IQR = Q3 − Q1)
- **Les moustaches** = plage des valeurs normales
- **Les outliers** = valeurs extrêmes (masquées ici pour la lisibilité)


---

## Solution

```python

upper = robots.groupby("type")["downtime"].apply(upper_whisker).max()
sns.boxplot(data=robots, x="type", y="downtime", showfliers=False)
plt.ylim(0, upper * 1.05)
plt.title("Distribution du downtime par type (coeur de distribution)")
plt.xlabel("Type de robot")
plt.ylabel("Downtime (s)")
plt.tight_layout()
plt.show()
```

La mediane = ligne dans la boite, la  variabilite = hauteur de la boite (IQR). Les outliers sont masques ici pour la lisibilite.

---

##Boxplot downtime par type

<img src="./assets/dataviz_robots/downtime_boxplot_by_robot_type.png" alt="Boxplot downtime par type de robot" width="800" />

---

## Boxplot — lecture explicite 

- boite: de `Q1` (25%) a `Q3` (75%)
- ligne dans la boite: `mediane` (`Q2`)
- `IQR = Q3 - Q1`
- moustaches: dernier point dans `[Q1 - 1.5*IQR ; Q3 + 1.5*IQR]`
- outliers: points hors moustaches

```python
s = df.loc[df["robot_type"] == "carrier", "downtime_s"]
q1, q2, q3 = s.quantile([0.25, 0.50, 0.75])
iqr = q3 - q1
low, high = q1 - 1.5 * iqr, q3 + 1.5 * iqr
nb_outliers = ((s < low) | (s > high)).sum()
```

Pratique conseillee:
afficher le coeur de distribution dans le boxplot, et reporter `nb_outliers` a part.

<img src="./assets/dataviz_robots/boxplot_reading_guide.png" alt="Guide de lecture boxplot" width="800" />

---

## Pourquoi autant d'outliers sur ce dataset ?

1. La regle boxplot (`1.5 * IQR`) marque vite les queues longues.
2. `downtime_s` est asymetrique: beaucoup de petites valeurs + quelques incidents longs.
3. Le dataset simule des pics d'incidents (14h-16h, zone `C3`) pour la detection d'anomalies.

Ordre de grandeur observe:
- environ `241 / 5406` points (`4.46%`) classes outliers sur `downtime_s`.
