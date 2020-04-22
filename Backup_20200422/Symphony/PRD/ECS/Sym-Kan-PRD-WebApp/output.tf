output "alb_output" {
  # ECSOutput-1
  value = "${aws_alb.aws_ecs_alb.dns_name}"
}
