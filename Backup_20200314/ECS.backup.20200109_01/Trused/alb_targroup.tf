resource "aws_alb_target_group" "uat-auditevents" {
  name       = "${var.ecs_name}-uat-audit"
  port       = 8001
  protocol   = "${var.aws_alb_protocol}"
  vpc_id     = "${var.vpc_name}"
  depends_on = [aws_alb.aws_ecs_alb]

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 300
  }

  health_check {
    path                = "/"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200,301,302"
  }
}

resource "aws_alb_target_group" "uat-checklistcrawler" {
  name       = "${var.ecs_name}-uat-check"
  port       = 8002
  protocol   = "${var.aws_alb_protocol}"
  vpc_id     = "${var.vpc_name}"
  depends_on = [aws_alb.aws_ecs_alb]

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 300
  }

  health_check {
    path                = "/"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200,301,302"
  }
}

resource "aws_alb_target_group" "uat-dataaudit" {
  name       = "${var.ecs_name}-uat-dataaudit"
  port       = 8003
  protocol   = "${var.aws_alb_protocol}"
  vpc_id     = "${var.vpc_name}"
  depends_on = [aws_alb.aws_ecs_alb]

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 300
  }

  health_check {
    path                = "/"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200,301,302"
  }
}


resource "aws_alb_target_group" "uat-elasticsearchindexer" {
  name       = "${var.ecs_name}-uat-elastic"
  port       = 8004
  protocol   = "${var.aws_alb_protocol}"
  vpc_id     = "${var.vpc_name}"
  depends_on = [aws_alb.aws_ecs_alb]

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 300
  }

  health_check {
    path                = "/"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200,301,302"
  }
}



resource "aws_autoscaling_attachment" "uat-auditevents" {
  autoscaling_group_name = "${aws_autoscaling_group.ecs-cluster.name}"
  alb_target_group_arn   = "${aws_alb_target_group.uat-auditevents.arn}"
}

resource "aws_autoscaling_attachment" "checklistcrawler" {
  autoscaling_group_name = "${aws_autoscaling_group.ecs-cluster.name}"
  alb_target_group_arn   = "${aws_alb_target_group.uat-checklistcrawler.arn}"
}

resource "aws_autoscaling_attachment" "dataaudit" {
  autoscaling_group_name = "${aws_autoscaling_group.ecs-cluster.name}"
  alb_target_group_arn   = "${aws_alb_target_group.uat-dataaudit.arn}"
}

resource "aws_autoscaling_attachment" "elasticsearchindexer" {
  autoscaling_group_name = "${aws_autoscaling_group.ecs-cluster.name}"
  alb_target_group_arn   = "${aws_alb_target_group.uat-elasticsearchindexer.arn}"
}

resource "aws_autoscaling_attachment" "uat-jobs" {
  autoscaling_group_name = "${aws_autoscaling_group.ecs-cluster-2[0].name}"
  alb_target_group_arn   = "${aws_alb_target_group.ecs-group.arn}"
}

