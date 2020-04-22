resource "aws_autoscaling_notification" "ecs_notification" {
  # ASG_ALARM-1
  group_names = [
    "${aws_autoscaling_group.ecs-cluster.name}",
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = "${aws_sns_topic.usage_notifications.arn}"
}

resource "aws_autoscaling_notification" "ecs_notification-2" {
  # ASG_ALARM-2
  count       = "${var.second_asg ? 1 : 0}"
  group_names = [
    "${aws_autoscaling_group.ecs-cluster-2[count.index].name}",
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = "${aws_sns_topic.usage_notifications.arn}"
}
