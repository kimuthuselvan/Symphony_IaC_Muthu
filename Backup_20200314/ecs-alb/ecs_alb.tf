#
#
#variable "aws_access_key_id" {}
#variable "aws_secret_access_key" {}
variable "region_name" {}
variable "keypair_name" {}
variable "vpc_name" {}
variable "subnet_name_az1" {}
variable "subnet_name_az2" {}
variable "sg_name" {}
variable "instance_type" {}
variable "no_of_instance" {}
variable "ecs_name" {}
variable "max_instance_size" {}
variable "min_instance_size" {}
variable "desired_capacity" {}
variable "ami_id" {}
variable "container_image" {}
variable "container_version" {}
variable "container_desired_count" {}
variable "aws_alb_protocol" {}
variable "container_Port" {}
variable "host_Port" {}
variable "aws_iam_ecs_service_role" {}
variable "aws_iam_ecs_ec2_role" {}
variable "aws_iam_role_policy" {}
variable "project_name" {}
variable "client_name" {}
variable "environment_name" {}
#
#
provider "aws" {
#  access_key = var.aws_access_key_id
#  secret_key = var.aws_secret_access_key
  region = var.region_name
}
#
#
resource "aws_alb" "aws_ecs_alb" {
  name     = "${var.ecs_name}-ALB"
  subnets  = ["${var.subnet_name_az1}", "${var.subnet_name_az2}"]
  security_groups = ["${var.sg_name}"]
  enable_http2    = "true"
  idle_timeout    = 600
  internal = true
  
  tags = {
    Name = "${var.ecs_name}-ALB"
    Region = "${var.region_name}"
    Project = "${var.project_name}"
    Client = "${var.client_name}"
    Environment = "${var.environment_name}"
  }
}

output "alb_output" {
  value = "${aws_alb.aws_ecs_alb.dns_name}"
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.aws_ecs_alb.id}"
  port              = "${var.host_Port}"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.ecs-group.id}"
    type             = "forward"
  }
  #default_action {
  #  type = "redirect"
  #  redirect {
  #    port = "443"
  #    protocol = "HTTPS"
  #    status_code = "HTTP_301"
  #  }
  #}
}

resource "aws_alb_target_group" "ecs-group" {
  name       = "${var.ecs_name}-ALB-TG"
  port       = "${var.host_Port}"
  protocol   = "${var.aws_alb_protocol}"
  vpc_id     = "${var.vpc_name}"
  depends_on = [aws_alb.aws_ecs_alb]

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
  }

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 60
    interval            = 300
    matcher             = "200,301,302"
  }

  tags = {
    Name = "${var.ecs_name}-ALB-TG"
    Region = "${var.region_name}"
    Project = "${var.project_name}"
    Client = "${var.client_name}"
    Environment = "${var.environment_name}"
  }
}

# User data for ECS cluster
data "template_file" "ecs-cluster" {
  template = "${file("ecs-cluster.tpl")}"

  vars = {
    ecs_cluster = "${aws_ecs_cluster.ecs_cluster.name}"
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.ecs_name}"

  tags = {
    Name = "${var.ecs_name}"
    Region = "${var.region_name}"
    Project = "${var.project_name}"
    Client = "${var.client_name}"
    Environment = "${var.environment_name}"
  }
}

resource "aws_autoscaling_group" "ecs-cluster" {
  name                      = "${var.ecs_name}-ASG"
  vpc_zone_identifier       = ["${var.subnet_name_az1}", "${var.subnet_name_az2}"]
  min_size                  = "${var.min_instance_size}"
  max_size                  = "${var.max_instance_size}"
  desired_capacity          = "${var.desired_capacity}"
  launch_configuration      = "${aws_launch_configuration.ecs-cluster-lc.name}"
  health_check_grace_period = 120
  default_cooldown          = 30
  termination_policies      = ["OldestInstance"]

  #tags = {
  #  Name = "${var.ecs_name}_ASG"
  #  Region = "${var.region_name}"
  #  Project = "${var.project_name}"
  #  Client = "${var.client_name}"
  #  Environment = "${var.environment_name}"
  #  propagate_at_launch = true
  #}
  tag {
    key                 = "Name"
    value               = "${var.ecs_name}-ASG"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "ecs-cluster" {
  name                      = "${var.ecs_name}_ASP"
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = "90"
  adjustment_type           = "ChangeInCapacity"
  autoscaling_group_name    = "${aws_autoscaling_group.ecs-cluster.name}"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 70.0
  }
}

resource "aws_launch_configuration" "ecs-cluster-lc" {
  name_prefix     = "${var.ecs_name}_LC"
  security_groups = ["${var.sg_name}"]

  key_name                    = "${var.keypair_name}"
  image_id                    = "${var.ami_id}"
  instance_type               = "${var.instance_type}"
  iam_instance_profile        = "${aws_iam_instance_profile.ecs-ec2-role.id}"
  user_data                   = "${data.template_file.ecs-cluster.rendered}"
  associate_public_ip_address = false

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_instance_profile" "ecs-ec2-role" {
  name = "ecs-ec2-role-kansas-uat-dmz"
  role = "${var.aws_iam_ecs_ec2_role}"
}

resource "aws_ecs_service" "ecs_service" {
  name            = "${var.container_image}"
  cluster         = "${aws_ecs_cluster.ecs_cluster.id}"
  task_definition = "${aws_ecs_task_definition.ecs_service.arn}"
  desired_count   = "${var.container_desired_count}"
  iam_role        = "${var.aws_iam_ecs_service_role}"
  depends_on      = [aws_iam_role_policy_attachment.ecs-service-attach]

  load_balancer {
    target_group_arn = "${aws_alb_target_group.ecs-group.id}"
    container_name   = "${var.container_image}"
    container_port   = "${var.container_Port}"
  }

}

resource "aws_ecs_task_definition" "ecs_service" {
  family = "${var.container_image}"

  container_definitions = <<EOF
[
  {
    "portMappings": [
      {
        "hostPort": ${var.host_Port},
        "protocol": "tcp",
        "containerPort": ${var.container_Port}
      }
    ],
    "memoryReservation" : 128,
    "image": "${var.container_image}:${var.container_version}",
    "essential": true,
    "name": "${var.container_image}",
    "logConfiguration": {
    "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/${var.ecs_name}/${var.container_image}",
        "awslogs-region": "${var.region_name}",
        "awslogs-stream-prefix": "${var.ecs_name}"
      }
    }
  }
]
EOF
}

resource "aws_cloudwatch_log_group" "ecs_service" {
  name = "/${var.ecs_name}/${var.container_image}"
}

resource "aws_iam_role_policy_attachment" "ecs-service-attach" {
  role       = "${var.aws_iam_ecs_service_role}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}
