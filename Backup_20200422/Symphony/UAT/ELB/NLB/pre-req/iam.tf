resource "aws_iam_role_policy" "static_lb_lambda" {
  name = "lambdaFunction-NLB-to-ALB-policy"
  role = aws_iam_role.static_lb_lambda.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:*:*:*"
      ],
      "Effect": "Allow",
      "Sid": "LambdaLogging"
    },
    {
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "*",
      "Effect": "Allow",
      "Sid": "S3"
    },
    {
      "Action": [
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:DeregisterTargets"
      ],
      "Resource": "*",
      "Effect": "Allow",
      "Sid": "ChangeTargetGroups"
    },
    {
      "Action": [
        "elasticloadbalancing:DescribeTargetHealth"
      ],
      "Resource": "*",
      "Effect": "Allow",
      "Sid": "DescribeTargetGroups"
    },
    {
      "Action": [
        "cloudwatch:putMetricData"
      ],
      "Resource": "*",
      "Effect": "Allow",
      "Sid": "CloudWatch"
    }
  ]
}
EOF
}

resource "aws_iam_role" "static_lb_lambda" {
  name        = "lambdaFunction-NLB-to-ALB-role"
  description = "For lamba function NLB-to-ALB"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
