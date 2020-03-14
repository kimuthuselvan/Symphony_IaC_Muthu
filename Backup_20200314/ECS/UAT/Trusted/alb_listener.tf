resource "aws_lb_listener" "httptohttps" {
  load_balancer_arn = "${aws_alb.aws_ecs_alb.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

