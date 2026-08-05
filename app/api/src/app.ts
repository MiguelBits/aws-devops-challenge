import cors from "cors"
import express, { type Express, type Request, type Response } from "express"
import type { Pool } from "pg"
import { logger } from "./logger"
import type { ClickMetrics } from "./metrics"

interface MessageResponse {
  message: string
  totalClicks: number
}

export const createApp = (pool: Pool, metrics: ClickMetrics): Express => {
  const app = express()
  app.use(cors())
  app.use(express.json())

  app.get("/health", async (_req: Request, res: Response) => {
    try {
      await pool.query("SELECT 1")
      res.json({ status: "ok", db: "up" })
    } catch (error) {
      logger.error({ err: error }, "health check falhou")
      res.status(503).json({ status: "degraded", db: "down" })
    }
  })

  app.get("/api/message", async (_req: Request, res: Response) => {
    try {
      const { rows } = await pool.query<{ text: string }>(
        "SELECT text FROM messages ORDER BY id LIMIT 1",
      )
      await pool.query("INSERT INTO clicks DEFAULT VALUES")
      const { rows: countRows } = await pool.query<{ count: string }>(
        "SELECT count(*) AS count FROM clicks",
      )
      const totalClicks = Number(countRows[0].count)
      void metrics.recordClick()
      logger.info({ event: "button_click", totalClicks }, "clique registado")
      const payload: MessageResponse = {
        message: rows[0]?.text ?? "sem mensagens na base de dados",
        totalClicks,
      }
      res.json(payload)
    } catch (error) {
      logger.error({ err: error }, "falha ao obter mensagem")
      res.status(500).json({ error: "internal_error" })
    }
  })

  return app
}
