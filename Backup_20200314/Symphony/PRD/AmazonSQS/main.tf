provider "aws" {
  region = "us-east-1"
}

resource "aws_sqs_queue" "terraform_queue" {
  name                      = "Symphony-Kansas-PRD-SQS"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
  #redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.terraform_queue_deadletter.arn}\",\"maxReceiveCount\":4}"

  tags = {
    Name = "Symphony-Kansas-PRD-SQS"
    Project = "Symphony"
    Client = "Kansas"
    Environment = "UAT"
    Zone = "Trusted"
  }
}
