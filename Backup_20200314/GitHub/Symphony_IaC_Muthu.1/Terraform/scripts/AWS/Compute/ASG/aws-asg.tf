provider "aws" {
  region = "us-east-1"
}

resource "aws_launch_configuration" "main_launch_cfg" {
  name_prefix = "${var.name_prefix}_asg_"
  image_id = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  enable_monitoring           = "${var.enable_monitoring}"
  security_groups = ["${aws_security_group.main_sg.id}"]
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "main_asg" {
  name              = "${var.asg_name}"
  min_size          = "${var.min_size}"
  desired_capacity  = "${var.desired_capacity}"
  max_size          = "${var.max_size}"
  health_check_type = "${var.health_check_type}"

  launch_configuration = "${aws_launch_configuration.main_launch_cfg.name}"
  vpc_zone_identifier = flatten(["${var.subnet_1a}","${var.subnet_1b}"])

  #tags = {
   # Name = "${var.name_prefix}_ASG"
    #Project = "Symphony"
    #Organization = "Advantasure Inc."
    #Client = "Kansas"
  #}
}

resource "aws_security_group" "main_sg" {
  name_prefix = "${var.name_prefix}_sg"
  description = "Allow all inbound traffic"
  vpc_id      = "${var.vpc_id}"

 lifecycle {
    create_before_destroy = true
  }
}

#resource "aws_security_group_rule" "allow_all_ssh" {
#  type              = "ingress"
#  from_port         = 22
#  to_port           = 22
#  protocol          = "tcp"
#  cidr_blocks       = flatten(["10.126.128.0/26", "10.126.128.64/26"])
#  security_group_id = "sg-0ac5d6e7b7732cf47"
#}


#resource "aws_security_group_rule" "allow_all_outbound" {
#  type              = "egress"
#  from_port         = 0
#  to_port           = 0
#  protocol          = "-1"
#  cidr_blocks       = ["0.0.0.0/0"]
#  security_group_id = "sg-0ac5d6e7b7732cf47"
#}

#resource "aws_security_group_rule" "allow_ping" {
#  type              = "ingress"
#  from_port         = 8
#  to_port           = 0
#  protocol          = "icmp"
#  cidr_blocks       = ["0.0.0.0/0"]
#  security_group_id = "sg-0ac5d6e7b7732cf47"
#}

resource "aws_lb_target_group" "main_lb_tg" {
  name = "${var.tg_name}"
  port = "${var.port}"
  protocol = "${var.protocol}"
  vpc_id = "${var.vpc_id}"
}

resource "aws_lb" "mainlb" {
  name = "${var.lb_name}"
  internal = "${var.internal}"
  load_balancer_type = "${var.load_balancer_type}"
  subnets = ["${var.subnet_1a}","${var.subnet_1b}"]
  #enable_deletion_protection = true

  tags = {
    Name = "${var.name_prefix}_lb"
    Project = "Symphony"
    Organization = "Advantasure Inc."
    Client = "Kansas"
  }
}

