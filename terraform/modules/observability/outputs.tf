output "sns_topic_arn" {
  value = aws_sns_topic.alarms.arn
}

output "alarm_name" {
  value = aws_cloudwatch_metric_alarm.button_clicks.alarm_name
}
