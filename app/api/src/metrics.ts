import { CloudWatchClient, PutMetricDataCommand } from "@aws-sdk/client-cloudwatch"
import { logger } from "./logger"

export interface ClickMetrics {
  recordClick(): Promise<void>
}

const NAMESPACE = process.env.METRICS_NAMESPACE ?? "ChallengeApp"
const ENABLED = process.env.ENABLE_CLOUDWATCH_METRICS === "true"

const client = ENABLED ? new CloudWatchClient({}) : null

export const clickMetrics: ClickMetrics = {
  async recordClick() {
    if (!client) return
    try {
      await client.send(
        new PutMetricDataCommand({
          Namespace: NAMESPACE,
          MetricData: [
            {
              MetricName: "ButtonClicks",
              Value: 1,
              Unit: "Count",
              Dimensions: [{ Name: "Service", Value: "api" }],
            },
          ],
        }),
      )
    } catch (error) {
      logger.warn({ err: error }, "falha ao publicar a métrica ButtonClicks")
    }
  },
}
