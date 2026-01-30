# TP — Shop App (client React uniquement)

Objectif : construire une **app client React** (TanStack Query) qui consomme une API fournie et affiche les données du fil rouge **`shop`**.

## Ce qui est fourni

- Une stack Docker : Postgres + MongoDB + Adminer
- Les scripts de seed (Postgres + MongoDB)
- Une mini API Node (sans Express) qui expose des endpoints JSON (code commenté)
- Un squelette client React (à compléter)

Le dossier de départ est : `TPs/app-project-starter/`.

## Ce que vous devez faire

Vous ne touchez **que** au dossier `client/` :

- (Question 1) Afficher la liste des customers (nom + email) avec un `fetch` simple vers l'API
- (Question 2) Refactorer cette partie avec TanStack Query
- Pouvoir sélectionner un customer et afficher ses commandes + items
- Ajouter un mode “Toutes les commandes” (sans filtre client)
- Gérer les états `loading` / `error` / `empty`
- Utiliser TanStack Query correctement (query keys, cache, refetch)

Bonus (si vous avez le temps) :
- Recherche (filtre par nom/email)
- Pagination côté UI
- Calcul et affichage du total par commande
- UI propre (layout + composants)

## Démarrage (starter)

Dupliquez le starter dans votre dossier de travail (au choix) :

```bash
cp -R TPs/app-project-starter ./tp-app-project
cd tp-app-project
```

Puis suivez les étapes ci-dessous dans ce dossier.

## 1) Lancer les conteneurs

Depuis le dossier `tp-app-project` :

```bash
docker compose up -d
```

### Détail du `docker-compose.yml`

Fichier : `docker-compose.yml`

- Contenu :

```yaml
services:
  postgres:
    image: postgres:17-alpine
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: shop
    ports:
      - "5433:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./shared:/shared:ro

  mongodb:
    image: mongo:7
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: root
      MONGO_INITDB_DATABASE: shop
    ports:
      - "27017:27017"
    volumes:
      - mongo_data:/data/db
      - ./shared:/shared:ro

  adminer:
    image: adminer:4
    ports:
      - "8080:8080"
    depends_on:
      - postgres

volumes:
  postgres_data:
  mongo_data:
```

- Service `postgres`
  - Image : `postgres:17-alpine`
  - DB : `shop` (créée au premier démarrage)
  - Port hôte : `5433` → conteneur `5432` (évite les conflits avec un Postgres local sur `5432`)
  - Volume persistant : `postgres_data`
  - Montage seeds : `./shared:/shared:ro`
- Service `mongodb`
  - Image : `mongo:7`
  - Auth : `root` / `root` (auth DB `admin`)
  - Port hôte : `27017`
  - Volume persistant : `mongo_data`
  - Montage seeds : `./shared:/shared:ro`
- Service `adminer`
  - UI web pour Postgres : `http://localhost:8080`

## 2) Seed des bases (à la main)

### Seed Postgres

```bash
docker compose exec postgres psql -U postgres -d shop -v ON_ERROR_STOP=1 -f /shared/postgres/seed.sql
```

### Seed MongoDB (optionnel pour ce TP)

```bash
docker compose exec mongodb mongosh -u root -p root --authenticationDatabase admin --file /shared/mongodb/seed.js
```

## 3) Lancer l'API

Dans `api/` :

```bash
npm i
npm run dev
```

Endpoints :
- `GET http://localhost:4000/api/pg/customers`
- `GET http://localhost:4000/api/pg/orders`
- `GET http://localhost:4000/api/pg/orders?customerId=1`

## 4) Lancer le client (à compléter)

Dans `client/` :

```bash
npm i
npm run dev
```

Le proxy Vite est déjà configuré : `/api` → `http://localhost:4000`.

## Question 1 — Connexion à l'API (fetch)

Objectif : afficher les customers sans TanStack Query, juste avec `fetch`.

Exemple :

```js
useEffect(() => {
  (async () => {
    const res = await fetch("/api/pg/customers");
    if (!res.ok) {
      throw new Error(`${res.status} ${res.statusText}`);
    }
    const data = await res.json();
    // setData
  })().catch(setError);
}, []);
```

## Question 2 — Refactor avec TanStack Query

Objectif : remplacer la logique `useEffect/useState` par TanStack Query.

1) Installer : `npm i @tanstack/react-query`
2) Ajouter le `QueryClientProvider` dans `main.jsx`
3) Refactorer :

```js
// récupération des données
const customersQuery = useQuery({
  queryKey: ["customers"],
  queryFn: async () => {
    const res = await fetch("/api/pg/customers");
    // classique pour la gestion des erreurs
    if (!res.ok) throw new Error(`${res.status} ${res.statusText}`);
    return res.json();
  },
});
```

Conseils (query keys) :
- customers : `["customers"]`
- commandes (toutes) : `["orders", "all"]`
- commandes (par customer) : `["orders", customerId]` (activée seulement si `customerId` existe)

## Défis avancés (pour les plus à l’aise)

1) Prefetch : au survol d’un customer, précharger ses commandes (`queryClient.prefetchQuery`) pour que l’affichage soit instantané.
2) Deep-link : synchroniser l’UI avec l’URL (`?customerId=...&view=orders`) et restaurer l’état au refresh.

## Question guidée — “Drizzle, ça se met où ?”

Réponse attendue :
- **Côté API (serveur)**, pas dans le client React.
- Drizzle sert à faire la couche accès DB (schéma + requêtes + migrations) dans le code Node.

## Bonus serveur (optionnel) — Ajouter Drizzle (guide, minimal)

Objectif : remplacer un `pool.query(...)` par une requête Drizzle (sans tout réécrire).

1) Installer (dans `api/`) :

```bash
npm i drizzle-orm pg
npm i -D drizzle-kit
```

2) Créer une config Drizzle (ex: `api/drizzle.config.ts`) qui pointe vers `process.env.PG_CONNECTION_STRING`.

3) Définir le schéma (ex: `api/src/db/schema.ts`) :

```ts
import { pgTable, serial, varchar, timestamp } from "drizzle-orm/pg-core";

export const customers = pgTable("customers", {
  id: serial("id").primaryKey(),
  email: varchar("email", { length: 255 }).notNull(),
  firstName: varchar("first_name", { length: 100 }).notNull(),
  lastName: varchar("last_name", { length: 100 }).notNull(),
  createdAt: timestamp("created_at").notNull(),
});
```

4) Initialiser Drizzle (ex: `api/src/db/index.ts`) :

```ts
import { Pool } from "pg";
import { drizzle } from "drizzle-orm/node-postgres";

const pool = new Pool({ connectionString: process.env.PG_CONNECTION_STRING });
export const db = drizzle(pool);
```

5) Exemple d’usage (remplacer un `SELECT` customers) :

```ts
import { db } from "./db";
import { customers } from "./db/schema";

const rows = await db.select().from(customers);
```

Important :
- Drizzle est **optionnel** dans ce TP (bonus serveur).
- Si vous allez jusqu’aux migrations : regardez `drizzle-kit generate` / `drizzle-kit push` (sans le détail ici).
