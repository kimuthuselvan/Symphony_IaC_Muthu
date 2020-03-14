
resource "aws_alb_listener_rule" "auditevents" {
  listener_arn = "${aws_alb_listener.front_end.arn}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.uat-auditevents.arn}"
  }

  condition {
    path_pattern {
      values = ["/api/auditevents*"]
    }
  }
}


resource "aws_alb_listener_rule" "checklistcrawler" {
  listener_arn = "${aws_alb_listener.front_end.arn}"
  priority     = 120

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.uat-checklistcrawler.arn}"
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
    target_group_arn = "${aws_alb_target_group.uat-dataaudit.arn}"
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
    target_group_arn = "${aws_alb_target_group.uat-elasticsearchindexer.arn}"
  }

  condition {
    path_pattern {
      values = ["/api/elasticsearchindexer*"]
    }
  }
}

