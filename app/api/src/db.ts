import { Pool } from "pg"

export const createPool = (): Pool =>
  new Pool({
    host: process.env.PGHOST ?? "localhost",
    port: Number(process.env.PGPORT ?? 5432),
    user: process.env.PGUSER ?? "challenge",
    password: process.env.PGPASSWORD ?? "challenge",
    database: process.env.PGDATABASE ?? "challenge",
    max: 5,
  })

const MIGRATIONS = `
CREATE TABLE IF NOT EXISTS messages (
  id serial PRIMARY KEY,
  text text NOT NULL
);
CREATE TABLE IF NOT EXISTS clicks (
  id bigserial PRIMARY KEY,
  clicked_at timestamptz NOT NULL DEFAULT now()
);
`

export const migrate = async (pool: Pool): Promise<void> => {
  await pool.query(MIGRATIONS)
  const { rows } = await pool.query<{ count: string }>("SELECT count(*) AS count FROM messages")
  if (Number(rows[0].count) === 0) {
    await pool.query("INSERT INTO messages (text) VALUES ($1)", [
      "Olá do desafio AWS & DevOps! Esta mensagem veio do PostgreSQL.",
    ])
  }
}
