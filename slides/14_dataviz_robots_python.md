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

On pourra se poser les questions suivantes et certainement y répondre en étudiant le Dataset:
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

### Indicateurs opérationnels - champ de notre dataset

- Durée mission : `mission_duration_s`
- Temps d'arrêt : `downtime_s`
- Batterie : `battery_pct`
- Vitesse : `speed_mps`
- Température : `temperature_c`

---

### Fiabilité - champ de notre dataset

- `error_code`
- `mission_status`
- `incident_label`

---

# Exploitation & KPI Potentiels

- Missions par heure / zone
- Durée moyenne par type de tâche
- Charge par robot

---

## Fiabilité

- Taux d'erreur global
- Taux d'incident par robot
- Corrélation batterie ↔ erreurs

---

##  Une fois notre analyse réalisé on pourra 

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

df["timestamp"] = pd.to_datetime(df["timestamp"], errors="coerce") # NaT

print(df)
print(df.dtypes)

```

---

- Sans errors="coerce", pandas lance une exception si une valeur ne peut pas être convertie.

```python
s = pd.Series(["10", "20", "abc"])
pd.to_numeric(s) # ValueError: Unable to parse string "abc" at position 2

```

- errors='coerce'
- errors='raise' (lance une exception)

---

## Application `to_numeric`

> Transformez les valeurs en données numériques, même si Python infère déjà certaines valeurs tout seul.

---

## Solution 

```python
# Types numériques attendus
num_cols = ['mission_duration_s', 'downtime_s', 'battery_pct', 'speed_mps', 'temperature_c']
for c in num_cols:
    robots[c] = pd.to_numeric(robots[c], errors='coerce')

```

---

## Chargement + qualite des donnees

```python
# Suppression des doublons
robots = robots.drop_duplicates()

# Conserver uniquement les missions dont la durée est strictement positive
robots = robots[robots["duration"] > 0]

# Conserver uniquement les pourcentages de batterie valides (entre 0 et 100 inclus)
robots = robots[robots["battery_level"].between(0, 100)]

robots["hour"] = robots["event_ts"].dt.hour
robots["day"] = robots["event_ts"].dt.date
robots["is_error"] = np.where(robots["error"].notna(), 1, 0)
# Mesurer l'efficience 
robots["efficiency"] = robots["duration"] / ( robots["downtime"] + robots["duration"] )
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
# Mesurer l'efficience 
robots["efficiency"] = robots["duration"] / ( robots["downtime"] + robots["duration"] )
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

> identifier creux/pics et les rapprocher des missions des robots.

---

## Rendu — Missions par heure

<img src="./assets/dataviz_robots/missions_by_hour.png" alt="Missions par heure" width="800" />

---

## Distribution batterie

```python
sns.histplot(robots, x="battery_level", bins=20, kde=True, color="#1f77b4")
plt.title("Distribution du niveau de batterie")
plt.xlabel("Batterie (%)")
plt.ylabel("Frequence")
plt.tight_layout()
plt.show()
```

si batterie sous 20%, risque d'arret operationnel.

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

## Il y a environ 26% de robot chargés à 100%

Cela peut vouloir dire:

- Flotte en attente
- Recharge récemment terminée
- Faible activité opérationnelle

---

# Pour aller plus loin

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

# Visualiser les tranches qui permettent de regrouper les robots en fonction de leur charge
robots[["battery_bin", "id", "battery_level"]]
```

> Proposez un graphique permettant d'évaluer la relation entre le niveau de batterie et le taux d'erreur.

---

# La solution

```python

error_by_battery = robots.groupby("battery_bin", as_index=False).agg(
    is_error=("is_error", "mean"),
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

- La variable `is_error` est binaire (0 = pas d'erreur, 1 = erreur, changé lors du nettoyage des données)
- La moyenne d'une variable binaire correspond à un taux.

---

## Solution attendue

```python
zone_err = robots.groupby("zone", as_index=False).agg(
    is_error = ("is_error", "mean")
).sort_values("is_error", ascending=False)

sns.barplot(data=zone_err, x="zone", y="is_error", color="red")
plt.title("Taux d'erreur moyen par zone")
plt.xlabel("Taux d'erreur")
plt.ylabel("Zone")
plt.tight_layout()
plt.show()
```


---

## Erreurs par zone

<img src="./assets/dataviz_robots/error_rate_by_zone.png" alt="Erreurs par zone" width="800" />

---

## Lecture analytique concrète d'un boxplot

Un boxplot résume une distribution en 5 valeurs : minimum, Q1, médiane, Q3, maximum.

1. La **boîte (entre Q1 et Q3)** contient 50 % des données : elle représente le **comportement central et habituel** du système.
1. La **ligne au centre** est la médiane : le niveau typique.
1. Les **moustaches et points isolés** montrent les valeurs extrêmes ou atypiques.

> La boîte décrit la situation statistiquement normale, les extrêmes signalent les cas particuliers.

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

---

# Exercice — Analyse de la variabilité du downtime 3/3

3. Construisez un boxplot du downtime par type de robot :
   - en masquant les outliers,
   - en limitant l'axe vertical au cœur de la distribution.

4. Interprétez :
   - la médiane,
   - la variabilité,
   - les différences entre types de robots.


---

## Solution - `showfliers=False` retire les outliers

```python
sns.boxplot(data=robots, x="type", y="downtime", showfliers=False)
plt.title("Distribution du downtime par type (coeur de distribution)")
plt.xlabel("Type de robot")
plt.ylabel("Downtime (s)")
plt.tight_layout()
plt.show()
```

La mediane = ligne dans la boite, la  variabilite = hauteur de la boite (IQR). Les outliers sont masques ici pour la lisibilite.

---

## Boxplot downtime par type

<img src="./assets/dataviz_robots/downtime_boxplot_by_robot_type.png" alt="Boxplot downtime par type de robot" width="800" />

---

## Boxplot — Les outliers

Remarque: loc sert à sélectionner des lignes et/ou des colonnes par étiquette, généralement avec une condition logique.

```python
s = robots.loc[robots["type"] == "carrier", "downtime"]
q1, q2, q3 = s.quantile([0.25, 0.50, 0.75])
iqr = q3 - q1
low, high = q1 - 1.5 * iqr, q3 + 1.5 * iqr
nb_outliers = ((s < low) | (s > high)).sum()
```

Pratique conseillee:
afficher le coeur de distribution dans le boxplot, et reporter `nb_outliers` a part.

---

## Pourquoi autant d'outliers sur ce dataset ?

1. La regle boxplot (`1.5 * IQR`) marque vite les queues longues.
2. `downtime` est asymetrique: beaucoup de petites valeurs + quelques incidents longs.
3. Le dataset simule des pics d'incidents (14h-16h, zone `C3`) pour la detection d'anomalies, valeurs d'un seul coup importantes.

```txt
|| || || || || || ||        |
petits incidents         gros incident
```

---

# Corrélations : principe et calcul

> Mesurer l'intensité et le sens des relations entre variables quantitatives d'un dataset étudié.

---

## Coefficient de corrélation (Pearson)

`r \in [-1 ; 1]`

- **+1** → relation linéaire positive forte
- **0** → absence de relation linéaire
- **−1** → relation linéaire négative forte

---

# Exemple simple : dataset simulé


```python

np.random.seed(42)

# Création d'un petit dataset simulé
df = pd.DataFrame({
    "marketing_spend": np.random.normal(100, 15, 100),
})

# Création de variables corrélées
df["sales"] = df["marketing_spend"] * 2.5 + np.random.normal(0, 20, 100)
df["customer_satisfaction"] = df["sales"] * 0.05 + np.random.normal(3, 0.5, 100)
df["support_tickets"] = 200 - df["customer_satisfaction"] * 20 + np.random.normal(0, 5, 100)

df.head()
```

Structure logique simulée :

- Marketing → influence positive sur ventes
- Ventes → influence positive sur satisfaction
- Satisfaction → influence négative sur tickets support

---

## Calcul de la matrice de corrélation

```python
corr_matrix = df.corr(numeric_only=True)
print(corr_matrix)
```

---

##  Visualisation Heatmap

```python

plt.figure(figsize=(8, 6))

sns.heatmap(
    corr_matrix,
    annot=True,
    fmt=".2f",
    cmap="coolwarm",
    square=True,
    linewidths=0.5
)

plt.title("Correlation Matrix Heatmap")
plt.tight_layout()
plt.show()
```

---

## Rendu attendu

![Image](https://seaborn.pydata.org/_images/structured_heatmap.png)


---

## Lecture attendue

- `marketing_spend` ↔ `sales` → corrélation positive forte

**Si marketing_spend augmente, sales augmente quasi proportionnellement.**

- `sales` ↔ `customer_satisfaction` → positive modérée

**Les ventes influencent la satisfaction, mais d'autres facteurs jouent également.**

- `customer_satisfaction` ↔ `support_tickets` → négative forte

**Une meilleure satisfaction réduit fortement la charge support.**

```python
sales = marketing_spend * 2.5 + bruit
customer_satisfaction = sales * 0.05 + bruit
support_tickets = 200 - customer_satisfaction * 20 + bruit
```