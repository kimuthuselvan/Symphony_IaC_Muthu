resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  count               = var.ec2_enable_monitoring
  alarm_name          = "${var.default_tags["client_name"]}-CPUmetrix"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions = [
        "${data.aws_sns_topic.notification.arn}"
    ]

  tags = merge(
    var.default_tags,
    map(
      "service_name", "Cloudwatch"
    )
  )
}
