resource "aws_cloudwatch_log_group" "ecs_service" {
  # ECSclouwatch-1
  name = "/${var.default_tags["project_name"]}/${var.default_tags["client_name"]}/${var.ecs_name}"
  tags = merge(
    var.default_tags,
    map(
      "service_name", "Cloudwatch"
    )
  )
}