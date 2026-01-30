# API — Shop (sans Express)

API fournie pour le TP (vous n’avez pas besoin de la modifier).

## Démarrer

Depuis `tp-app-project/api` :

```bash
pnpm i
pnpm run dev
```

## Variables d’environnement

- `PORT` (défaut `4000`)
- `PG_CONNECTION_STRING` (défaut `postgresql://postgres:postgres@localhost:5433/shop`)

## Endpoints

- `GET /api/pg/customers` → liste des customers
- `GET /api/pg/orders` → toutes les commandes + items
- `GET /api/pg/orders?customerId=1` → commandes + items d’un customer
