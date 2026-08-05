import { useState } from "react"

interface MessageResponse {
  message: string
  totalClicks: number
}

const App = () => {
  const [data, setData] = useState<MessageResponse | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

  const handleClick = async (): Promise<void> => {
    setLoading(true)
    setError(null)
    try {
      const response = await fetch("/api/message")
      if (!response.ok) throw new Error(`HTTP ${response.status}`)
      setData((await response.json()) as MessageResponse)
    } catch {
      setError("Não foi possível falar com a API.")
    } finally {
      setLoading(false)
    }
  }

  return (
    <main className="flex min-h-screen items-center justify-center bg-slate-950 px-4 text-slate-100">
      <div className="w-full max-w-md rounded-2xl border border-slate-800 bg-slate-900 p-8 text-center">
        <p className="text-xs font-semibold uppercase tracking-widest text-sky-400">
          Desafio AWS &amp; DevOps
        </p>
        <h1 className="mt-2 text-2xl font-bold">Mensagem do PostgreSQL</h1>
        <p className="mt-2 text-sm text-slate-400">
          Cada clique chama a API Node, lê a mensagem na base de dados e regista um evento.
        </p>
        <button
          type="button"
          onClick={handleClick}
          disabled={loading}
          aria-label="Obter mensagem da API"
          className="mt-6 w-full rounded-xl bg-sky-500 px-6 py-3 font-semibold text-slate-950 transition hover:bg-sky-400 disabled:cursor-not-allowed disabled:opacity-60"
        >
          {loading ? "A carregar..." : "Obter mensagem"}
        </button>
        <div aria-live="polite" className="mt-6 min-h-12">
          {error ? (
            <p role="alert" className="text-sm text-rose-400">
              {error}
            </p>
          ) : null}
          {data ? (
            <div className="rounded-xl border border-slate-800 bg-slate-950 p-4">
              <p className="text-sm">{data.message}</p>
              <p className="mt-2 text-xs text-slate-500">
                Total de cliques registados: {data.totalClicks}
              </p>
            </div>
          ) : null}
        </div>
      </div>
    </main>
  )
}

export default App
