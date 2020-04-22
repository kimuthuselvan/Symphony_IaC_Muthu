
resource "aws_sns_topic" "usage_notifications" {
  name = "usage-notifications"
}

resource "null_resource" "sns_subscribe" {
  depends_on = [ aws_sns_topic.usage_notifications ]
  triggers = {
    sns_topic_arn = "${aws_sns_topic.usage_notifications.arn}"
  }
  count = length(var.emails)

  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${aws_sns_topic.usage_notifications.arn} --protocol email --notification-endpoint ${element(var.emails, count.index)}"
  }
}
