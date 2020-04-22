# User data for first ASG instances
data "template_file" "ecs-cluster" {
  # Userdata-file-1
  template = "${file("${var.user_data_file}")}"

  vars = {
    ecs_cluster = "${aws_ecs_cluster.ecs_cluster.name}"
  }
}

# User data for second ASG instances
data "template_file" "ecs-cluster-2" {
  # Userdata-file-2
  template = "${file("${var.user_data_file_2}")}"

  vars = {
    ecs_cluster = "${aws_ecs_cluster.ecs_cluster.name}"
  }
}

resource "aws_autoscaling_group" "ecs-cluster" {
  # ECSASG-1
  name                      = "${var.ecs_name}_ASG_${var.running-os}"
  vpc_zone_identifier       = data.aws_subnet_ids.subnet_ids.ids
  min_size                  = "${var.min_instance_size}"
  max_size                  = "${var.max_instance_size}"
  desired_capacity          = "${var.desired_capacity}"
  launch_template {
    id      = aws_launch_template.ecs-cluster-lt.id
    version = "$Latest"
  }
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
      # 1
      key                 = "Name"
      value               = "${var.ecs_name}_ASG_${var.running-os}"
      propagate_at_launch = true
  }
  tag {
      # 2
      key                 = "OS_Type"
      value               = "Linux"
      propagate_at_launch = true
  }
  tag {
      # 3
      key                 = "OS_Name"
      value               = "Amazon Linux 2"
      propagate_at_launch = true
  }
  tag {
      # 4
      key                 = "service_name"
      value               = "EC2"
      propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "ecs-cluster-2" {
  # ECSASG-2
  count                     = "${var.second_asg ? 1 : 0}"
  name                      = "${var.ecs_name}_ASG_${var.running-os_2}"
  vpc_zone_identifier       = data.aws_subnet_ids.subnet_ids.ids
  min_size                  = "${var.min_instance_size}"
  max_size                  = "${var.max_instance_size}"
  desired_capacity          = "${var.desired_capacity}"
  launch_template {
    id      = aws_launch_template.ecs-cluster-lt-2[count.index].id
    version = "$Latest"
  }
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
      # 1
      key                 = "Name"
      value               = "${var.ecs_name}_ASG_${var.running-os_2}"
      propagate_at_launch = true
  }
  tag {
      # 2
      key                 = "OS_Type"
      value               = "Windows"
      propagate_at_launch = true
  }
  tag {
      # 3
      key                 = "OS_Name"
      value               = "Windows 2019"
      propagate_at_launch = true
  }
  tag {
      # 4
      key                 = "service_name"
      value               = "EC2"
      propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "ecs-cluster" {
  # ECSASG-3
  name                      = "${var.ecs_name}_autoscaling_${var.running-os}"
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


resource "aws_autoscaling_policy" "ecs-cluster-2" {
  # ECSASG-4
  count                     = "${var.second_asg ? 1 : 0}"
  name                      = "${var.ecs_name}_autoscaling_${var.running-os_2}"
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = "90"
  adjustment_type           = "ChangeInCapacity"
  autoscaling_group_name    = "${aws_autoscaling_group.ecs-cluster-2[count.index].name}"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 70.0
  }
}

resource "aws_launch_template" "ecs-cluster-lt" {
  # ECSASG-5
  name_prefix     = "${var.ecs_name}-LC-${var.running-os}"

  key_name                    = "${var.ecs_name}-Key"
  image_id                    = "${var.ami_id}"
  instance_type               = "${var.instance_type}"
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs-ec2-role.id
  }
  user_data                   = "${base64encode(data.template_file.ecs-cluster.rendered)}"
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.security_group.id]
    delete_on_termination       = true
  }

  block_device_mappings {
    #device_name = "${var.ecs_name}-Volume-${var.running-os}"
    device_name = "/dev/xvda"

    ebs {
      volume_size = 50
      encrypted = true
      delete_on_termination = true
    }
  }
  tag_specifications {
    resource_type = "volume"

    #tags = var.default_tags
    tags = merge(
      var.default_tags,
      map(
        "Name", "${var.ecs_name}-Volume-${var.running-os}"
      )
    )
  }

}

resource "aws_launch_template" "ecs-cluster-lt-2" {
  # ECSASG-6
  count           = "${var.second_asg ? 1 : 0}"
  name_prefix     = "${var.ecs_name}-LC-${var.running-os_2}"

  key_name                    = "${var.ecs_name}-Key"
  image_id                    = "${var.ami_id_2}"
  instance_type               = "${var.instance_type}"
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs-ec2-role.id
  }
  user_data                   = "${base64encode(data.template_file.ecs-cluster-2.rendered)}"
  network_interfaces {
    associate_public_ip_address = false
    security_groups = [aws_security_group.security_group.id]
    delete_on_termination       = true
  }

  block_device_mappings {
   #device_name = "${var.ecs_name}-Volume-${var.running-os_2}"
    device_name = "/dev/sda1"

    ebs {
      volume_size = 50
      encrypted = true
      delete_on_termination = true
    }
  }
  tag_specifications {
    resource_type = "volume"

    #tags = var.default_tags
    tags = merge(
      var.default_tags,
      map(
        "Name", "${var.ecs_name}-Volume-${var.running-os_2}"
      )
    )
  }
}

resource "aws_iam_instance_profile" "ecs-ec2-role" {
  # ECSASG-7
  name = "${var.ecs_name}-iam-instance-profile"
  role = "${var.aws_iam_ecs_ec2_role}"
}
