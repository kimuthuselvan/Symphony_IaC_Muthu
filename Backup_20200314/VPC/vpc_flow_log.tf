provider "aws" {
  region = var.region_name
}

resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn    = "${aws_iam_role.vpc_flow_log.arn}"
  log_destination = "${aws_cloudwatch_log_group.vpc_flow_log.arn}"
  traffic_type    = "ALL"
  vpc_id          = var.vpc_id
}

resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  name = var.log_group_name
}

resource "aws_iam_role" "vpc_flow_log" {
  name = "VPC_Flow_Logs"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "vpc_flow_log" {
  name        = "VPC_Flow_Logs"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "vpc_flow_log" {
  role       = "${aws_iam_role.vpc_flow_log.name}"
  policy_arn = "${aws_iam_policy.vpc_flow_log.arn}"
}

