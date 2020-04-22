provider "aws" {
  region = var.region_name
}

## Collect VPC and Subnets IDs
data "aws_vpc" "vpc_id" {
  filter {
    name   = "tag:Name"
    values = var.vpc_name
  }
}

data "aws_subnet_ids" "subnet_ids" {
  vpc_id   = data.aws_vpc.vpc_id.id
  filter {
    name   = "tag:Name"
    values = var.subnet_names
  }
}

## Create S3 bucket to store target IPs
resource "aws_s3_bucket" "static_lb" {
  bucket = lower("${var.ecs_name}-lambda-alb2nlb-${var.region_name}")
  acl    = "private"
  region = "us-east-1"
  force_destroy = "true"

  versioning {
    enabled = false
  }
}

resource "aws_cloudwatch_event_rule" "cron_minute" {
  name                = "cron-min-${var.ecs_name}"
  schedule_expression = "rate(1 minute)"
  is_enabled          = true
}

resource "aws_lb" "app_public" {
  name                       = "${var.ecs_name}-NLB"
  load_balancer_type         = "network"
  internal                   = false
  subnets                    = data.aws_subnet_ids.subnet_ids.ids

  tags     = var.default_tags
}


## Create Target groups in NLB

resource "aws_lb_target_group" "app_public_80" {
  name              = "${var.ecs_name}-TCP80"
  port              = 80
  protocol          = "TCP"
  target_type       = "ip"
  vpc_id            = data.aws_vpc.vpc_id.id
  proxy_protocol_v2 = false

  tags              = var.default_tags
}

resource "aws_lb_target_group" "app_public_443" {
  name              = "${var.ecs_name}-TCP443"
  port              = 443
  protocol          = "TCP"
  target_type       = "ip"
  vpc_id            = data.aws_vpc.vpc_id.id
  proxy_protocol_v2 = false

  tags              = var.default_tags
}

## Setup NLB Listeners to forward to target groups created above

resource "aws_lb_listener" "app_public_80" {
  load_balancer_arn = aws_lb.app_public.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_public_80.arn
  }
}

resource "aws_lb_listener" "app_public_443" {
  load_balancer_arn = aws_lb.app_public.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_public_443.arn
  }
}

## Create lambda function for each target groups

resource "aws_lambda_function" "static_lb_updater_80" {
  filename      = "populate_NLB_TG_with_ALB.zip"
  function_name = "${var.ecs_name}-Populate-NLB-with-ALB-HTTP"
  role          = aws_iam_role.static_lb_lambda.arn
  handler       = "populate_NLB_TG_with_ALB.lambda_handler"

  source_code_hash = filebase64sha256("populate_NLB_TG_with_ALB.zip")

  runtime     = "python2.7"
  memory_size = 128
  timeout     = 300

  environment {
    variables = {
      ALB_DNS_NAME                      = var.alb_dns_name
      ALB_LISTENER                      = "80"
      S3_BUCKET                         = aws_s3_bucket.static_lb.bucket
      NLB_TG_ARN                        = aws_lb_target_group.app_public_80.arn
      MAX_LOOKUP_PER_INVOCATION         = 50
      INVOCATIONS_BEFORE_DEREGISTRATION = 3
      CW_METRIC_FLAG_IP_COUNT           = true
      AZ1 = "${var.region_name}a"
      AZ2 = "${var.region_name}b"
      NET1 = var.subnet_cidr_az1
      NET2 = var.subnet_cidr_az2
    }
  }
}

resource "aws_lambda_function" "static_lb_updater_443" {
  filename      = "populate_NLB_TG_with_ALB.zip"
  function_name = "${var.ecs_name}-Populate-NLB-with-ALB-HTTPS"
  role          = aws_iam_role.static_lb_lambda.arn
  handler       = "populate_NLB_TG_with_ALB.lambda_handler"

  source_code_hash = filebase64sha256("populate_NLB_TG_with_ALB.zip")

  runtime     = "python2.7"
  memory_size = 128
  timeout     = 300

  environment {
    variables = {
      ALB_DNS_NAME                      = var.alb_dns_name
      ALB_LISTENER                      = "443"
      S3_BUCKET                         = aws_s3_bucket.static_lb.bucket
      NLB_TG_ARN                        = aws_lb_target_group.app_public_443.arn
      MAX_LOOKUP_PER_INVOCATION         = 50
      INVOCATIONS_BEFORE_DEREGISTRATION = 3
      CW_METRIC_FLAG_IP_COUNT           = true
    }
  }
}



resource "aws_cloudwatch_event_target" "static_lb_updater_80" {
  rule      = aws_cloudwatch_event_rule.cron_minute.name
  target_id = "${var.ecs_name}-port80"
  arn       = aws_lambda_function.static_lb_updater_80.arn
}

resource "aws_cloudwatch_event_target" "static_lb_updater_443" {
  rule      = aws_cloudwatch_event_rule.cron_minute.name
  target_id = "${var.ecs_name}-port443"
  arn       = aws_lambda_function.static_lb_updater_443.arn
}


## add permissions to each Lambda function to allow them to be triggered by Cloudwatch

resource "aws_lambda_permission" "allow_cloudwatch_80" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.static_lb_updater_80.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cron_minute.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_443" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.static_lb_updater_443.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cron_minute.arn
}
