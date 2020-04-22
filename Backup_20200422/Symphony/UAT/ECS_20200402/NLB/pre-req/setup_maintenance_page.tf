provider "aws" {
  region = var.region_name
}

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
    bucket_url = "${aws_s3_bucket.contentbucket.bucket}.s3-website-${var.region_name}.amazonaws.com"
  }
}

resource "aws_alb" "aws_security_alb" {
  name     = "${var.default_tags["project_name"]}-${var.default_tags["service_role"]}-ALB"
  internal = true
  subnets  = var.subnet_id
  security_groups = [aws_security_group.security_group.id]
  idle_timeout    = 600

  tags = var.default_tags
}

output "alb_output" {
  value = aws_alb.aws_security_alb.name
}

resource "aws_lb_listener" "httptohttps" {
  load_balancer_arn = aws_alb.aws_security_alb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.aws_security_alb.id
  port              = var.alb_list_port
  protocol          = var.aws_alb_protocol
  certificate_arn   = var.certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.security-group.id
    type             = "forward"
  }
}

resource "aws_alb_target_group" "security-group" {
  name       = "${var.default_tags["project_name"]}-${var.default_tags["service_role"]}-TG"
  port       = var.alb_target_port
  protocol   = var.aws_alb_protocol
  vpc_id     = var.vpc_id
  depends_on = [aws_alb.aws_security_alb]

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 300
  }
  health_check {
    path                = "/"
    protocol            = var.aws_alb_protocol
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
  }
}

resource "aws_security_group" "security_group" {
  name        = "${var.default_tags["project_name"]}_${var.default_tags["service_role"]}_${var.default_tags["os_type"]}"
  description = "Security Group for maintenance page setup"
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

resource "aws_autoscaling_group" "linuxservers" {
  name   = "${var.default_tags["project_name"]}_${var.default_tags["service_role"]}_${var.default_tags["os_type"]}_ASG"
  vpc_zone_identifier       = var.subnet_id
  min_size                  = var.min_instance_size
  max_size                  = var.max_instance_size
  desired_capacity          = var.desired_capacity
  launch_configuration      = aws_launch_configuration.launchlinux.name
  health_check_grace_period = 120
  default_cooldown          = 30
  termination_policies      = ["OldestInstance"]
  depends_on                = [aws_s3_bucket.contentbucket, aws_s3_bucket_object.uploadfiles, aws_alb_target_group.security-group]

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
    value               = "${var.default_tags["project_name"]}_${var.default_tags["client_name"]}_${var.default_tags["security_zone"]}_${var.default_tags["os_type"]}"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "linuxautopolicy" {
  name   = "${var.default_tags["project_name"]}_${var.default_tags["service_role"]}_${var.default_tags["os_type"]}_ASGP"
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = "90"
  adjustment_type           = "ChangeInCapacity"
  autoscaling_group_name    = aws_autoscaling_group.linuxservers.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 70.0
  }
}

resource "aws_launch_configuration" "launchlinux" {
  name   = "${var.default_tags["project_name"]}_${var.default_tags["service_role"]}_${var.default_tags["os_type"]}_LC"
  security_groups = [aws_security_group.security_group.id]

  key_name                    = var.key_name
  image_id                    = data.aws_ami.amazon-linux-2.id
  instance_type               = var.instance_type
  user_data                   = data.template_file.userdata.rendered
  associate_public_ip_address = false

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_attachment" "asg_attachment_alb" {
  autoscaling_group_name = aws_autoscaling_group.linuxservers.id
  alb_target_group_arn   = aws_alb_target_group.security-group.arn
}

