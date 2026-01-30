import { useEffect, useState } from "react";

export default function App() {
  const [customers, setCustomers] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    (async () => {
      const res = await fetch("/api/pg/customers");
      if (!res.ok) throw new Error(`${res.status} ${res.statusText}`);
      setCustomers(await res.json());
    })().catch((e) => setError(e instanceof Error ? e : new Error(String(e))));
  }, []);

  return (
    <div style={{ padding: 24, fontFamily: "system-ui" }}>
      <h1 style={{ fontSize: 24, fontWeight: 700, marginBottom: 12 }}>
        TP Shop Client
      </h1>
      <p style={{ marginBottom: 16 }}>
        TODO: Question 1 = fetch, Question 2 = TanStack Query.
      </p>

      {!customers && !error ? <p>Loading…</p> : null}
      {error ? <p>Error: {error.message}</p> : null}
      {customers ? (
        <pre style={{ whiteSpace: "pre-wrap" }}>
          {JSON.stringify(customers, null, 2)}
        </pre>
      ) : null}
    </div>
  );
}

