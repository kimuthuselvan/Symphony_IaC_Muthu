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
    #self      = true
    from_port = 0
    to_port   = 0
    cidr_blocks = [ "10.126.0.0/16" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = merge(
    var.default_tags,
    map(
      "Name", "${var.default_tags["project_name"]}_${var.default_tags["application_name"]}_${var.default_tags["environment_name"]}_${var.default_tags["os_type"]}_SG"
    )
  )

 #tags = var.default_tags
}

resource "aws_autoscaling_group" "windowsservers" {
  count                     = "${var.require_ASG == true ? length(var.subnet_id) : 0}"
  name   = "${var.default_tags["project_name"]}_${var.default_tags["application_name"]}_${var.default_tags["environment_name"]}_${var.default_tags["os_type"]}_ASG_${var.subnet_name[count.index]}"
  vpc_zone_identifier       = [ var.subnet_id[count.index] ]
  min_size                  = var.min_instance_size
  max_size                  = var.max_instance_size
  desired_capacity          = var.desired_capacity
  launch_configuration      = aws_launch_configuration.launchwindows[0].name
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
  count                     = "${var.require_ASG == true ? length(var.subnet_id) : 0}"
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
  count                        = "${var.require_ASG == true ? 1 : 0}"
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


resource "aws_instance" "dou_proxy" {
  count           = "${var.require_ASG == true ? 0 : length(var.subnet_id) }"
  ami             = data.aws_ami.windows-2019.id
  instance_type   = var.instance_type
  #volume_type     = var.volume_type
  #vloume_size     = var.vloume_size
  key_name        = var.key_name
  security_groups = [ aws_security_group.security_group.id ]
  subnet_id       = var.subnet_id[count.index]
  user_data       = data.template_file.userdata.rendered

  root_block_device {
    volume_type = var.volume_type
    volume_size = var.volume_size
    encrypted = true
  }

  volume_tags = {
    Name = "${var.default_tags["project_name"]}_${var.default_tags["application_name"]}_${var.default_tags["environment_name"]}_${var.default_tags["os_type"]}_${var.subnet_name[count.index]}"
  }

  tags = merge(
    var.default_tags,
    map(
      "Name", "${var.default_tags["project_name"]}_${var.default_tags["application_name"]}_${var.default_tags["environment_name"]}_${var.default_tags["os_type"]}_${var.subnet_name[count.index]}"
    )
  )

}

