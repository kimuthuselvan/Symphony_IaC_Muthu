## VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  instance_tenancy     = "default"

  tags = {
    Name         = var.vpc_name
    Project      = var.project_name
    Organization = var.organization_name
    Client       = var.client_name
    AWS_Account  = var.aws_account
  }
}

## Default Security Group
resource "aws_default_security_group" "default" {
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name         = "${var.vpc_name}-SG"
    Project      = var.project_name
    Organization = var.organization_name
    Client       = var.client_name
    AWS_Account  = var.aws_account
  }
}

## Subnet(s)
resource "aws_subnet" "private" {
  count = length(var.subnets_name)
  cidr_block = var.subnets_cidr_block[count.index]
  vpc_id = "${aws_vpc.main.id}"
  availability_zone = var.azs[count.index]

  tags = {
    Name         = var.subnets_name[count.index]
    Project      = var.project_name
    Organization = var.organization_name
    Client       = var.client_name
    AWS_Account  = var.aws_account
  }
}

## Routing

/**
resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn    = "${aws_iam_role.vpc_flow_log.arn}"
  log_destination = "${aws_cloudwatch_log_group.vpc_flow_log.arn}"
  traffic_type    = "ALL"
  vpc_id          = "${aws_vpc.main.id}"
}
 
resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  name = "/Network/Main/Flow_Logs"
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
**/
