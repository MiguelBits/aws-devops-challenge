import type { Pool } from "pg"
import request from "supertest"
import { createApp } from "./app"

const buildPool = (overrides: { failHealth?: boolean } = {}) => {
  const executed: string[] = []
  const query = async (sql: string): Promise<{ rows: unknown[] }> => {
    executed.push(sql)
    if (sql === "SELECT 1") {
      if (overrides.failHealth) throw new Error("db down")
      return { rows: [{ "?column?": 1 }] }
    }
    if (sql.startsWith("SELECT text")) return { rows: [{ text: "mensagem de teste" }] }
    if (sql.startsWith("SELECT count")) return { rows: [{ count: "7" }] }
    return { rows: [] }
  }
  return { pool: { query } as unknown as Pool, executed }
}

describe("API do desafio", () => {
  it("GET /health devolve ok quando a db responde", async () => {
    const { pool } = buildPool()
    const app = createApp(pool, { recordClick: async () => {} })
    const res = await request(app).get("/health")
    expect(res.status).toBe(200)
    expect(res.body).toEqual({ status: "ok", db: "up" })
  })

  it("GET /health devolve 503 quando a db falha", async () => {
    const { pool } = buildPool({ failHealth: true })
    const app = createApp(pool, { recordClick: async () => {} })
    const res = await request(app).get("/health")
    expect(res.status).toBe(503)
    expect(res.body.db).toBe("down")
  })

  it("GET /api/message lê a mensagem, regista o clique e emite métrica", async () => {
    const { pool, executed } = buildPool()
    const recordClick = jest.fn(async () => {})
    const app = createApp(pool, { recordClick })
    const res = await request(app).get("/api/message")
    expect(res.status).toBe(200)
    expect(res.body.message).toBe("mensagem de teste")
    expect(res.body.totalClicks).toBe(7)
    expect(executed.some((sql) => sql.startsWith("INSERT INTO clicks"))).toBe(true)
    expect(recordClick).toHaveBeenCalledTimes(1)
  })
})
