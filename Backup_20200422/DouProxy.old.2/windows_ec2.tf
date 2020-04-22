provider "aws" {
  region = var.region_name
}

# Find latest windows image
data "aws_ami" "windows-2019" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }

  #owners = ["801119661308"]
}

# User data for ASG instances
data "template_file" "userdata" {
  template = "${file("${var.user_data_file}")}"
  
  vars = {
    join_to_ad  = var.join_to_ad
  }
}

resource "aws_security_group" "security_group" {
  name        = "${var.default_tags["project_name"]}_${var.default_tags["application_name"]}_${var.default_tags["environment_name"]}_${var.default_tags["os_type"]}"
  description = "Security Group for Dou Proxy"
  vpc_id      = var.vpc_id

  ingress {
    protocol  = "-1"
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = var.default_tags
}

resource "aws_autoscaling_group" "windowsservers" {
  count                     = length(var.subnet_id)
  name   = "${var.default_tags["project_name"]}_${var.default_tags["application_name"]}_${var.default_tags["environment_name"]}_${var.default_tags["os_type"]}_ASG_${var.subnet_name[count.index]}"
  vpc_zone_identifier       = [ var.subnet_id[count.index] ]
  min_size                  = var.min_instance_size
  max_size                  = var.max_instance_size
  desired_capacity          = var.desired_capacity
  launch_configuration      = aws_launch_configuration.launchwindows.name
  health_check_grace_period = 120
  default_cooldown          = 30
  termination_policies      = ["OldestInstance"]

  dynamic "tag" {
    for_each = var.default_tags

    content {
      key    =  tag.key
      value   =  tag.value
      propagate_at_launch =  true
    }
  }
  tag {
    key                 = "Name"
    value               = "${var.default_tags["project_name"]}_${var.default_tags["application_name"]}_${var.default_tags["environment_name"]}_${var.default_tags["os_type"]}_${var.subnet_name[count.index]}"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "windowsautopolicy" {
  count                     = length(var.subnet_id)
  name   = "${var.default_tags["project_name"]}_${var.default_tags["application_name"]}_${var.default_tags["environment_name"]}_${var.default_tags["os_type"]}_ASG_${var.subnet_name[count.index]}"
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = "90"
  adjustment_type           = "ChangeInCapacity"
  autoscaling_group_name    = aws_autoscaling_group.windowsservers[count.index].name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 70.0
  }
}

resource "aws_launch_configuration" "launchwindows" {
  name   = "${var.default_tags["project_name"]}_${var.default_tags["application_name"]}_${var.default_tags["environment_name"]}_${var.default_tags["os_type"]}"
  security_groups = [aws_security_group.security_group.id]

  key_name                    = var.key_name
  image_id                    = data.aws_ami.windows-2019.id
  instance_type               = var.instance_type
  user_data                   = data.template_file.userdata.rendered
  associate_public_ip_address = false

  lifecycle {
    create_before_destroy = true
  }
}

