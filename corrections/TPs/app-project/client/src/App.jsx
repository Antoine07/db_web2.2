import { useQuery } from "@tanstack/react-query";

async function fetchJson(url) {
  const response = await fetch(url);
  if (!response.ok) {
    const text = await response.text().catch(() => "");
    throw new Error(`${response.status} ${response.statusText}${text ? ` — ${text}` : ""}`);
  }
  return response.json();
}

export default function App() {
  const customers = useQuery({
    queryKey: ["customers"],
    queryFn: () => fetchJson("/api/pg/customers"),
  });

  return (
    <>
      <header className="site-header">
        <a
          className="skip-link visually-hidden visually-hidden-focusable"
          href="#content"
        >
          Passer au contenu
        </a>

        <nav className="navbar" aria-label="Navigation principale">
          <div className="container navbar__inner">
            <div className="navbar-brand" href="/">
              Shop App
            </div>
            <div className="nav" aria-label="Sections"></div>
          </div>
        </nav>
      </header>

      <main className="page" id="content">
        <div className="container" style={{ display: "grid", gap: 16 }}>
          <section>
            <h2 style={{ fontWeight: 700, marginBottom: 8 }}>Customers</h2>
            {customers.isPending ? (
              <p>Chargement…</p>
            ) : customers.isError ? (
              <p>Erreur: {customers.error.message}</p>
            ) : (
              <pre style={{ whiteSpace: "pre-wrap" }}>
                {JSON.stringify(customers.data, null, 2)}
              </pre>
            )}
          </section>
        </div>
      </main>
    </>
  );
}
