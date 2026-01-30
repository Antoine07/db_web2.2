// Seed MongoDB pour la base `shop` (fil rouge e-commerce).
// Basé sur `data/shop_mongodb_seed.js`.

const shopDb = db.getSiblingDB("shop");
shopDb.dropDatabase();

const categoryTopsId = ObjectId("65a000000000000000000001");
const categoryPantsId = ObjectId("65a000000000000000000002");
const categoryShoesId = ObjectId("65a000000000000000000003");

shopDb.categories.insertMany([
  { _id: categoryTopsId, name: "Hauts", slug: "hauts" },
  { _id: categoryPantsId, name: "Pantalons", slug: "pantalons" },
  { _id: categoryShoesId, name: "Chaussures", slug: "chaussures" }
]);

const customerAliceId = ObjectId("65b000000000000000000001");
const customerBobId = ObjectId("65b000000000000000000002");
const customerChloeId = ObjectId("65b000000000000000000003");

shopDb.customers.insertMany([
  {
    _id: customerAliceId,
    email: "alice@demo.test",
    first_name: "Alice",
    last_name: "Martin",
    created_at: ISODate("2025-01-01T10:00:00Z"),
    address: { city: "Paris", country: "FR" },
    tags: ["vip", "newsletter"]
  },
  {
    _id: customerBobId,
    email: "bob@demo.test",
    first_name: "Bob",
    last_name: "Durand",
    created_at: ISODate("2025-01-03T09:30:00Z"),
    address: { city: "Lyon", country: "FR" },
    tags: []
  },
  {
    _id: customerChloeId,
    email: "chloe@demo.test",
    first_name: "Chloé",
    last_name: "Nguyen",
    created_at: ISODate("2025-01-05T18:15:00Z"),
    address: { city: "Bruxelles", country: "BE" },
    tags: ["newsletter"]
  }
]);

const productTshirtId = ObjectId("65c000000000000000000001");
const productHoodieId = ObjectId("65c000000000000000000002");
const productJeansId = ObjectId("65c000000000000000000003");
const productSneakersId = ObjectId("65c000000000000000000004");

shopDb.products.insertMany([
  {
    _id: productTshirtId,
    sku: "TOP-TS-001",
    name: "T-shirt basique noir",
    price: 14.0,
    stock: 120,
    category_id: categoryTopsId,
    attributes: { size: "M", color: "black" }
  },
  {
    _id: productHoodieId,
    sku: "TOP-HOOD-001",
    name: "Sweat à capuche gris",
    price: 49.0,
    stock: 25,
    category_id: categoryTopsId,
    attributes: { size: "L", color: "grey" }
  },
  {
    _id: productJeansId,
    sku: "PANT-JEANS-001",
    name: "Jean brut slim",
    price: 69.0,
    stock: 10,
    category_id: categoryPantsId,
    attributes: { waist: 32, length: 32, fit: "slim" }
  },
  {
    _id: productSneakersId,
    sku: "SHOE-SNK-001",
    name: "Baskets blanches",
    price: 89.0,
    stock: 0,
    category_id: categoryShoesId,
    attributes: { size_eu: 42, color: "white" }
  }
]);

shopDb.orders.insertMany([
  {
    _id: ObjectId("65d000000000000000000001"),
    customer_id: customerAliceId,
    status: "paid",
    ordered_at: ISODate("2025-01-10T12:00:00Z"),
    items: [
      {
        product_id: productTshirtId,
        product_name: "T-shirt basique noir",
        quantity: 2,
        unit_price: 14.0
      },
      {
        product_id: productSneakersId,
        product_name: "Baskets blanches",
        quantity: 1,
        unit_price: 89.0
      }
    ]
  },
  {
    _id: ObjectId("65d000000000000000000002"),
    customer_id: customerBobId,
    status: "pending",
    ordered_at: ISODate("2025-01-11T09:10:00Z"),
    items: [
      {
        product_id: productHoodieId,
        product_name: "Sweat à capuche gris",
        quantity: 1,
        unit_price: 49.0
      }
    ]
  },
  {
    _id: ObjectId("65d000000000000000000003"),
    customer_id: customerAliceId,
    status: "paid",
    ordered_at: ISODate("2025-01-12T20:05:00Z"),
    items: [
      {
        product_id: productJeansId,
        product_name: "Jean brut slim",
        quantity: 1,
        unit_price: 69.0
      }
    ]
  },
  {
    _id: ObjectId("65d000000000000000000004"),
    customer_id: customerChloeId,
    status: "canceled",
    ordered_at: ISODate("2025-01-13T15:30:00Z"),
    items: [
      {
        product_id: productSneakersId,
        product_name: "Baskets blanches",
        quantity: 1,
        unit_price: 89.0
      }
    ]
  }
]);

shopDb.products.createIndex({ sku: 1 }, { unique: true });
shopDb.orders.createIndex({ status: 1, ordered_at: -1 });
shopDb.orders.createIndex({ customer_id: 1, ordered_at: -1 });
shopDb.customers.createIndex({ email: 1 }, { unique: true });

print("OK: shop database seeded (customers/products/orders/categories).");
