import { createApp } from "./app"
import { createPool, migrate } from "./db"
import { logger } from "./logger"
import { clickMetrics } from "./metrics"

const PORT = Number(process.env.PORT ?? 3000)

const bootstrap = async (): Promise<void> => {
  const pool = createPool()
  await migrate(pool)
  const app = createApp(pool, clickMetrics)
  app.listen(PORT, () => logger.info({ port: PORT }, "api a ouvir"))
}

bootstrap().catch((error) => {
  logger.error({ err: error }, "falha no arranque da api")
  process.exit(1)
})
