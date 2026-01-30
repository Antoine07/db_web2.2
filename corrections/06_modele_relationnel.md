# Corrections — 06. Modèle relationnel

Diagramme UML (PlantUML) : `slides/assets/boutique_uml.svg` (source : `diagrams/boutique_uml.puml`)

Préparation (pour les exos Boutique, 1 à 6) :
```sql
\c shop
```

## Exercice 1 — Définitions solides (exemples)

- **PK** : identifiant officiel d'une ligne, unique et non NULL. Ex : `customers.id`.
- **FK** : colonne(s) qui référence(nt) une PK (ou une colonne UNIQUE). Ex : `orders.customer_id` → `customers.id`.
- **Clé candidate** : identifiant possible, unique, mais pas choisi comme PK. Ex : `customers.email` (UNIQUE).
- **NOT NULL** : interdit la valeur manquante. Ex : `orders.customer_id INT NOT NULL`.
- **UNIQUE** : interdit les doublons. Ex : `products.sku UNIQUE`.

## Exercice 2 — Identifier les clés (Boutique)

PK :
- `customers.id`, `orders.id`, `products.id`, `categories.id`
- `order_items (order_id, product_id)`

FK :
- `orders.customer_id` → `customers.id`
- `products.category_id` → `categories.id`
- `order_items.order_id` → `orders.id`
- `order_items.product_id` → `products.id`

## Exercice 3 — Cardinalités

- `customers` → `orders` : 1–N
- `orders` → `order_items` : 1–N
- `products` ↔ `orders` : N–N via `order_items`

## Exercice 4 — Contraintes (traduction)

```sql
-- email obligatoire et unique
email VARCHAR(255) NOT NULL UNIQUE
```

```sql
-- quantité strictement positive
quantity INT NOT NULL,
CONSTRAINT chk_quantity_positive CHECK (quantity > 0)
```

## Exercice 5 — Contraintes nommées

Intérêt :
- maintenance (`DROP CONSTRAINT fk_...`)
- lisibilité et debug
- conventions d'équipe

Exemple :
```sql
CONSTRAINT fk_orders_customer
  FOREIGN KEY (customer_id) REFERENCES customers(id)
```

## Exercice 6 — Suppression + `ON DELETE` (règles métier)

Exemples cohérents (parmi plusieurs choix possibles) :
- `customers → orders` : **RESTRICT** (on interdit de supprimer un client qui a des commandes).
- `orders → order_items` : **CASCADE** (une commande supprimée supprime ses lignes).
- `products → order_items` : **RESTRICT** (on empêche de supprimer un produit déjà vendu) ou **SET NULL** (si la ligne accepte `NULL`).

SQL (au moins `orders → order_items`) :
```sql
ALTER TABLE order_items
DROP CONSTRAINT fk_order_items_order;

ALTER TABLE order_items
  ADD CONSTRAINT fk_order_items_order
  FOREIGN KEY (order_id) REFERENCES orders(id)
  ON DELETE CASCADE;
```

Test sans risque :
```sql
BEGIN;
DELETE FROM orders WHERE id = 1;
ROLLBACK;
```

## Exercice 7 — Avions et pilotes

```sql
DROP DATABASE IF EXISTS aviation;
CREATE DATABASE aviation;

\c aviation

DROP TABLE IF EXISTS pilots;
DROP TABLE IF EXISTS planes;

CREATE TABLE planes (
  id INT NOT NULL,
  model VARCHAR(50) NOT NULL,
  CONSTRAINT pk_planes PRIMARY KEY (id)
);

CREATE TABLE pilots (
  id INT NOT NULL,
  name VARCHAR(50) NOT NULL,
  plane_id INT NULL,
  CONSTRAINT pk_pilots PRIMARY KEY (id),
  CONSTRAINT fk_pilots_plane
    FOREIGN KEY (plane_id) REFERENCES planes(id)
    ON DELETE SET NULL
);

INSERT INTO planes (id, model) VALUES
  (1, 'A320'),
  (2, 'B737');

INSERT INTO pilots (id, name, plane_id) VALUES
  (10, 'Alex', 1),
  (11, 'Sam', 1),
  (12, 'Kim', 2);
```

## Exercice 8 — Blog : `categories` et `posts` (PK + FK)

```sql
DROP DATABASE IF EXISTS blog;
CREATE DATABASE blog;

\c blog

DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS categories;

CREATE TABLE categories (
  id INT NOT NULL,
  name VARCHAR(50) NOT NULL,
  CONSTRAINT pk_categories PRIMARY KEY (id),
  CONSTRAINT uq_categories_name UNIQUE (name)
);

CREATE TABLE posts (
  id INT NOT NULL,
  title VARCHAR(100) NOT NULL,
  category_id INT NOT NULL,
  CONSTRAINT pk_posts PRIMARY KEY (id),
  CONSTRAINT fk_posts_category
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

INSERT INTO categories (id, name) VALUES
  (1, 'SQL'),
  (2, 'Backend');

INSERT INTO posts (id, title, category_id) VALUES
  (1, 'PK et FK', 1),
  (2, 'Contraintes SQL', 1),
  (3, 'API REST', 2);
```

## Exercice 9 — Blog : `comments` (FK + `ON DELETE`)

```sql
CREATE TABLE comments (
  id INT NOT NULL,
  content VARCHAR(200) NOT NULL,
  post_id INT NOT NULL,
  CONSTRAINT pk_comments PRIMARY KEY (id),
  CONSTRAINT fk_comments_post
    FOREIGN KEY (post_id) REFERENCES posts(id)
    ON DELETE CASCADE
);

INSERT INTO comments (id, content, post_id) VALUES
  (1, 'Top', 1),
  (2, 'Très clair', 1),
  (3, 'Merci !', 2),
  (4, 'Ok', 3);
```

## Exercice 10 — Vérifier les contraintes (succès/échec)

Attendu (si vous avez gardé le SQL ci-dessus) :
- Catégorie avec `name` en doublon : **échec** (`uq_categories_name`)
- Post avec `category_id` inexistant : **échec** (`fk_posts_category`)
- Commentaire avec `post_id` inexistant : **échec** (`fk_comments_post`)
- Supprimer un post qui a des commentaires : **succès** (les commentaires sont supprimés via **CASCADE**)
- Supprimer une catégorie qui a des posts : **échec** (RESTRICT/NO ACTION par défaut)

Exemples de tests :
```sql
BEGIN;

-- échec : doublon
INSERT INTO categories (id, name) VALUES (3, 'SQL');

-- échec : FK category inexistante
INSERT INTO posts (id, title, category_id) VALUES (4, 'Oops', 999);

-- succès : supprime aussi les commentaires du post 1
DELETE FROM posts WHERE id = 1;

-- échec : catégorie 1 encore référencée (par ex post 2)
DELETE FROM categories WHERE id = 1;

ROLLBACK;
```

## Exercice 11 — Faire évoluer la règle métier (modifier une FK)

Objectif : suppression d'une catégorie ⇒ `posts.category_id = NULL`.

```sql
ALTER TABLE posts ALTER COLUMN category_id DROP NOT NULL;

ALTER TABLE posts DROP CONSTRAINT fk_posts_category;

ALTER TABLE posts
  ADD CONSTRAINT fk_posts_category
  FOREIGN KEY (category_id) REFERENCES categories(id)
  ON DELETE SET NULL;

BEGIN;
DELETE FROM categories WHERE id = 2;
SELECT id, title, category_id FROM posts ORDER BY id;
ROLLBACK;
```
