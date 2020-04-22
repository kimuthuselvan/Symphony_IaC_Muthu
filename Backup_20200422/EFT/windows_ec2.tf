data "aws_ami" "windows-2016" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["Windows_Server-2016-English-Full-Base-*"]
  }
  
  #owners = ["801119661308"]
}

resource "aws_instance" "eft_windows" {
  #depends_on      = [aws_instance.eft_linux]
  count           = length(var.subnet_id)
  ami             = data.aws_ami.windows-2016.id
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = ["${var.sg_id}"]
  subnet_id       = var.subnet_id[count.index]
  user_data       = data.template_file.windows_ec2.rendered
  get_password_data = true

  connection {
    password = rsadecrypt(self.password_data,file("${var.key_name}.pem"))
  }

  root_block_device {
    encrypted = true
  }

  volume_tags = {
    Name = "${var.project_name}_${var.application_name}_${var.environment_name}_${var.windows_type}"
  }

  tags = {
    Name        = "${var.project_name}_${var.application_name}_${var.environment_name}_${var.windows_type}"
    Project     = "${var.project_name}"
    Client      = "${var.client_name}"
    Application = "${var.application_name}"
    Environment = "${var.environment_name}"
    OS          = "${var.windows_name}"
  }
}

data "template_file" "windows_ec2" {
  template = "${file("windows_ec2.tpl")}"
}

data "template_cloudinit_config" "windows_ec2" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.windows_ec2.rendered}"
  }
}

/**
resource "aws_lb" "eft_windows_lb" {
  name               = "symbhony-eft-windows-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = ["${var.sg_id}"]
  subnets            = var.subnet_id
  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "eft_windows_lb_tg" {
  name     = "symbhony-eft-windows-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}
**/
