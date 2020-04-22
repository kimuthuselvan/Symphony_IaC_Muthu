resource "aws_cloudwatch_event_rule" "cron_minute" {
  name                = "cron-minute-lambda"
  schedule_expression = "rate(1 minute)"
  is_enabled          = true
}

