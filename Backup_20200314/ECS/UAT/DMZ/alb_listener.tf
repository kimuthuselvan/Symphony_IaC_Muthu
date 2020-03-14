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

resource "aws_alb_listener_rule" "traceapi" {
  listener_arn = "${aws_alb_listener.front_end.arn}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.ecs-group[0].id}"
  }

  condition {
    path_pattern {
      values = ["/traceapi*"]
    }
  }
}

/*************************************************************************
resource "aws_alb_listener_rule" "checklistcrawler" {
  listener_arn = "${aws_alb_listener.front_end.arn}"
  priority     = 120

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.ecs-group[1].id}"
  }

  condition {
    path_pattern {
      values = ["/api/checklistcrawler*"]
    }
  }
}



resource "aws_alb_listener_rule" "dataaudit" {
  listener_arn = "${aws_alb_listener.front_end.arn}"
  priority     = 130

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.ecs-group[2].id}"
  }

  condition {
    path_pattern {
      values = ["/api/dataaudit*"]
    }
  }
}


resource "aws_alb_listener_rule" "elasticsearchindexer" {
  listener_arn = "${aws_alb_listener.front_end.arn}"
  priority     = 140

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.ecs-group[3].id}"
  }

  condition {
    path_pattern {
      values = ["/api/elasticsearchindexer*"]
    }
  }
}
*****************************************************************************/
