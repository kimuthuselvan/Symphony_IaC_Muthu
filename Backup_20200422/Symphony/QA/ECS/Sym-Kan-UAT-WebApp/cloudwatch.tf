resource "aws_cloudwatch_log_group" "ecs_service" {
  # ECSclouwatch-1
  name = "/${var.ecs_name}/${var.ecs_name}_logs"
  tags = merge(
    var.default_tags,
    map(
      "service_name", "Cloudwatch"
    )
  )
}
