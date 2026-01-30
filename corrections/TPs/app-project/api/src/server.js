import http from "node:http";
import { Pool } from "pg";

const port = Number(process.env.PORT || 4000);
const pool = new Pool({
  connectionString:
    process.env.PG_CONNECTION_STRING ||
    "postgresql://postgres:postgres@localhost:5433/shop",
});

http
  .createServer(async (req, res) => {
    if (req.method === "GET" && req.url === "/api/pg/customers") {
      try {
        const result = await pool.query(
          "SELECT id, email, first_name, last_name, phone, created_at FROM customers ORDER BY id;"
        );
        res.writeHead(200, { "content-type": "application/json; charset=utf-8" });
        res.end(JSON.stringify(result.rows));
      } catch (e) {
        res.writeHead(500, { "content-type": "application/json; charset=utf-8" });
        res.end(
          JSON.stringify({ error: e instanceof Error ? e.message : String(e) })
        );
      }
      return;
    }

    res.writeHead(404, { "content-type": "text/plain; charset=utf-8" });
    res.end("not found");
  })
  .listen(port);
