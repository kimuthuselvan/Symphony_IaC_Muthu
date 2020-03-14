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
variable "user_data_file" {}
variable "container_image" {}
variable "container_version" {}
variable "container_desired_count" {}
variable "aws_alb_protocol" {}
variable "container_Port" {}
variable "host_Port" {}
variable "aws_iam_ecs_service_role" {}
variable "aws_iam_ecs_ec2_role" {}
variable "aws_iam_role_policy" {}
variable "container_memory" {}
variable "project_name" {}
variable "client_name" {}
variable "environment_name" {}
variable "os_name" {}
#
#
provider "aws" {
  #access_key = var.aws_access_key_id
  #secret_key = var.aws_secret_access_key
  region = var.region_name
}
#
#
resource "aws_alb" "aws_ecs_alb" {
  name     = "${var.ecs_name}-ELB"
  internal = true
  subnets  = ["${var.subnet_name_az1}", "${var.subnet_name_az2}"]
  security_groups = ["${var.sg_name}"]
  enable_http2    = "true"
  idle_timeout    = 600

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
  port              = "${var.container_Port}"
  protocol          = "${var.aws_alb_protocol}"

  default_action {
    target_group_arn = "${aws_alb_target_group.ecs-group.id}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "ecs-group" {
  name       = "${var.ecs_name}-TG"
  port       = "${var.host_Port}"
  protocol   = "${var.aws_alb_protocol}"
  vpc_id     = "${var.vpc_name}"
  depends_on = [aws_alb.aws_ecs_alb]

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 300
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
  template = "${file("${var.user_data_file}")}"

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

  #tag {
  #  key                 = "Name"
  #  value               = "${var.ecs_name}-ASG"
  #  propagate_at_launch = true
  #}
  tags = [
    {
      key = "Name"
      value = "${var.ecs_name}-ASG"
      propagate_at_launch = true
    },
    {
      key = "Region"
      value = "${var.region_name}"
      propagate_at_launch = true
    },
    {
      key = "Project"
      value = "${var.project_name}"
      propagate_at_launch = true
    },
    {
      key = "Client"
      value = "${var.client_name}"
      propagate_at_launch = true
    },
    {
      key = "Environment"
      value = "${var.environment_name}"
      propagate_at_launch = true
    },
    {
      key = "OS"
      value = "${var.os_name}"
      propagate_at_launch = true
    }
  ]  
}

resource "aws_autoscaling_policy" "ecs-cluster" {
  name                      = "${var.ecs_name}-ASP"
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
  name_prefix     = "${var.ecs_name}-LC"
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
  name = "${var.ecs_name}-iam-instance-profile"
  role = "${var.aws_iam_ecs_ec2_role}"
}

resource "aws_ecs_service" "ecs_service" {
  name            = "${replace(var.container_image,"/","")}"
  cluster         = "${aws_ecs_cluster.ecs_cluster.id}"
  task_definition = "${aws_ecs_task_definition.ecs_service.arn}"
  desired_count   = "${var.container_desired_count}"
  iam_role        = "${var.aws_iam_ecs_service_role}"
  depends_on      = [aws_iam_role_policy_attachment.ecs-service-attach]

  load_balancer {
    target_group_arn = "${aws_alb_target_group.ecs-group.id}"
    container_name   = "${replace(var.container_image,"/","")}"
    container_port   = "${var.container_Port}"
  }

}

resource "aws_ecs_task_definition" "ecs_service" {
  family = "${replace(var.container_image,"/","")}"

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
    "memory" : ${var.container_memory},
    "image": "${var.container_image}:${var.container_version}",
    "essential": true,
    "name": "${replace(var.container_image,"/","")}",
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
