from sqlalchemy import create_engine, text
from sqlalchemy.orm import Session

DATABASE_URL = "postgresql+psycopg2://user:password@localhost:5432/dbname"

engine = create_engine(DATABASE_URL, future=True)

def place_order(customer_id: int, items: list[tuple[int, int, float]]) -> int | None:
    """
    items: list of (product_id, quantity, unit_price)
    Retourne order_id si OK, sinon None (stock insuffisant).
    """
    with Session(engine) as session:
        with session.begin():  # BEGIN ... COMMIT/ROLLBACK auto
            # SAVEPOINT
            session.execute(text("SAVEPOINT before_order"))

            # 1) Verrouiller les lignes produits concernées (ordre deterministe -> évite deadlocks)
            product_ids = sorted({pid for pid, _, _ in items})

            session.execute(
                text("""
                    SELECT id, stock
                    FROM products
                    WHERE id = ANY(:ids)
                    FOR UPDATE
                """),
                {"ids": product_ids},
            )

            # 2) Vérifier stock en base (après lock)
            stocks = dict(
                session.execute(
                    text("SELECT id, stock FROM products WHERE id = ANY(:ids)"),
                    {"ids": product_ids},
                ).all()
            )

            for pid, qty, _ in items:
                if pid not in stocks or stocks[pid] < qty:
                    # rollback partiel à before_order, puis on "sort" sans planter toute la transaction
                    session.execute(text("ROLLBACK TO SAVEPOINT before_order"))
                    return None

            # 3) Créer la commande
            order_id = session.execute(
                text("""
                    INSERT INTO orders (customer_id, status, ordered_at)
                    VALUES (:customer_id, 'pending', NOW())
                    RETURNING id
                """),
                {"customer_id": customer_id},
            ).scalar_one()

            # 4) Insérer les lignes
            session.execute(
                text("""
                    INSERT INTO order_items (order_id, product_id, quantity, unit_price)
                    VALUES (:order_id, :product_id, :quantity, :unit_price)
                """),
                [
                    {
                        "order_id": order_id,
                        "product_id": pid,
                        "quantity": qty,
                        "unit_price": price,
                    }
                    for pid, qty, price in items
                ],
            )

            # 5) Décrémenter le stock (toujours dans les locks)
            session.execute(
                text("""
                    UPDATE products p
                    SET stock = p.stock - v.quantity
                    FROM (
                        SELECT * FROM UNNEST(:pids::int[], :qtys::int[])
                        AS t(product_id, quantity)
                    ) AS v
                    WHERE p.id = v.product_id
                """),
                {
                    "pids": [pid for pid, _, _ in items],
                    "qtys": [qty for _, qty, _ in items],
                },
            )

            # fin du with session.begin() => COMMIT automatique
            return order_id


if __name__ == "__main__":
    order = place_order(
        customer_id=1,
        items=[
            (10, 1, 14.00),
            (12, 2, 65.00),
        ],
    )
    print("OK order_id =", order)  # None si stock insuffisant