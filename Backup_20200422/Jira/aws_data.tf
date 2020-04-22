## Collect VPC and Subnets IDs
data "aws_vpc" "vpc_id" {
  filter {
    name   = "tag:Name"
    values = var.vpc_name
  }
}

data "aws_subnet" "subnet_id" {
  vpc_id   = data.aws_vpc.vpc_id.id
  filter {
    name   = "tag:Name"
    values = var.subnet_name
  }
}

#data "aws_subnet_ids" "subnet_ids" {
#  vpc_id   = data.aws_vpc.vpc_id.id
#  filter {
#    name   = "tag:Name"
#    values = var.subnet_name
#  }
#}

#data "aws_acm_certificate" "clientdomain" {
#  domain      = var.domain_name
#  most_recent = true
#}

# Find latest amazon linux image
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# User data for ASG instances
data "template_file" "userdata" {
  template = "${file("${var.user_data_file}")}"
  vars = {
   #bucket_url = "${aws_s3_bucket.contentbucket.bucket}.s3-website-${var.region_name}.amazonaws.com"
  }
}
