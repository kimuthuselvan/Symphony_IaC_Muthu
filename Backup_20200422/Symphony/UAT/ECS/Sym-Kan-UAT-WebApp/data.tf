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

data "aws_acm_certificate" "clientdomain" {
  domain      = var.domain_name
  most_recent = true
}

data "aws_sns_topic" "notification" {
  name = var.sns_name
}
