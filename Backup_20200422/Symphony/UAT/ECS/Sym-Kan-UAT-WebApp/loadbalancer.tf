resource "aws_alb" "aws_ecs_alb" {
  # ECSALB-1
  name     = "${var.ecs_name}-ALB"
  internal = true
  subnets  = data.aws_subnet_ids.subnet_ids.ids
  security_groups = [aws_security_group.security_group.id]
  idle_timeout    = 600

  tags = merge(
    var.default_tags,
    map(
      "service_name", "ASG"
    )
  )
}

resource "aws_alb_listener" "front_end" {
  # ECSALB-Listener-1
  load_balancer_arn = "${aws_alb.aws_ecs_alb.id}"
  port              = "${var.alb_list_port}"
  protocol          = "${var.aws_alb_protocol}"
  certificate_arn   = data.aws_acm_certificate.clientdomain.arn

  default_action {
    target_group_arn = "${aws_alb_target_group.ecs-group[var.container_default_task].id}"
    type             = "forward"
  }
}

resource "aws_alb_listener_rule" "listener_rule" {
  # ECSALB-ListenerRule-1
  count      = "${length(var.container_def) - 1}"
  listener_arn = "${aws_alb_listener.front_end.arn}"

   action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.ecs-group[count.index].id}"
  }

  condition {
    path_pattern {
      values = ["${lookup(var.container_def[count.index], "listener_rule")}"]
    }
  }
}

resource "aws_lb_listener" "httptohttps" {
  # ECSALB-Listener-2
  load_balancer_arn = aws_alb.aws_ecs_alb.id
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


resource "aws_alb_target_group" "ecs-group" {
  # ECSALB-TargetGroup-1
  count      = "${length(var.container_def)}"
  name       = "${var.ecs_name}-${lookup(var.container_def[count.index], "name")}"
  port       = "${var.alb_target_port}"
  protocol   = "${var.aws_alb_protocol}"
  vpc_id     = data.aws_vpc.vpc_id.id
  depends_on = [aws_alb.aws_ecs_alb]

  health_check {
    path                = "${lookup(var.container_def[count.index], "searchpath")}"
    protocol            = "${var.aws_alb_protocol}"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "${lookup(var.container_def[count.index], "successcode")}"
  }

  tags = merge(
    var.default_tags,
    map(
      "service_name", "ASG"
    )
  )

}
