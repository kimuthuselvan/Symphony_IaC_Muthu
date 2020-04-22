data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_instance" "eft_linux" {
  #depends_on      = [aws_efs_mount_target.eft-efs-mt]
  count           = length(var.subnet_id)
  ami             = data.aws_ami.amazon-linux-2.id
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = ["${var.sg_id}"] 
  subnet_id       = var.subnet_id[count.index]
  user_data       = data.template_file.linux_ec2.rendered

  root_block_device {
    encrypted = true
  }

  volume_tags = {
    Name = "${var.project_name}_${var.application_name}_${var.environment_name}_${var.linux_type}"
  }

  tags = {
    Name        = "${var.project_name}_${var.application_name}_${var.environment_name}_${var.linux_type}"
    Project     = "${var.project_name}"
    Client      = "${var.client_name}"
    Application = "${var.application_name}"
    Environment = "${var.environment_name}"
    OS          = "${var.linux_name}"
  }
}


data "template_file" "linux_ec2" {
  template = "${file("${path.module}/linux_ec2.tpl")}"

  vars = {
    efs_dns_name = var.efs_dns_name
  }
}

data "template_cloudinit_config" "linux_ec2" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.linux_ec2.rendered}"
  }
}

/**
resource "aws_lb" "eft_linux_lb" {
  name               = "symbhony-eft-linux-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = ["${var.sg_id}"]
  subnets            = var.subnet_id
  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "eft_linux_lb_tg" {
  name     = "symbhony-eft-linux-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}
**/
