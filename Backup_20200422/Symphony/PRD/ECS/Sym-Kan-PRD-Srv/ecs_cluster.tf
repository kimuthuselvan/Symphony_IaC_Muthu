resource "aws_ecs_cluster" "ecs_cluster" {
  # ECSCluster-1
  name = "${var.ecs_name}"

  tags = var.default_tags

  #tags = merge(
  #  var.default_tags,
  #  map(
  #    "service_name", "ECS"
  #  )
  #)
}

resource "aws_ecs_service" "ecs_service" {
  # ECSCluster-2
  count           = "${length(var.container_def)}"
  name            = "${var.ecs_name}-${lookup(var.container_def[count.index], "name")}"
  cluster         = "${aws_ecs_cluster.ecs_cluster.id}"
  task_definition = "${aws_ecs_task_definition.ecs_service[count.index].arn}"
  desired_count   = "${var.container_desired_count}"
  iam_role        = "${var.aws_iam_ecs_service_role}"
  depends_on      = [aws_iam_role_policy_attachment.ecs-service-attach, aws_alb_listener.front_end, aws_alb_listener_rule.listener_rule]

  load_balancer {
    target_group_arn = "${aws_alb_target_group.ecs-group[count.index].id}"
    container_name   = "${var.ecs_name}-${lookup(var.container_def[count.index], "name")}"
    container_port   = "${var.container_port}"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.os-type==${lookup(var.container_def[count.index], "os_type")}"
  }

  #tags = merge(
  #  var.default_tags,
  #  map(
  #    "service_name", "ECS"
  #  )
  #)

  #propagate_tags = "SERVICE"
}

resource "aws_ecs_task_definition" "ecs_service" {
  # ECSCluster-3
  count           = "${length(var.container_def)}"
  family = "${var.ecs_name}-${lookup(var.container_def[count.index], "name")}"
  cpu = "${lookup(var.container_def[count.index], "cpu")}"
  memory = "${lookup(var.container_def[count.index], "memory")}"
  task_role_arn = "arn:aws:iam::945116902499:role/ecsTaskExecutionRole"
  execution_role_arn = "arn:aws:iam::945116902499:role/ecsTaskExecutionRole"
  container_definitions = "${data.template_file.ecs-tasks[count.index].rendered}"

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.os-type==${lookup(var.container_def[count.index], "os_type")}"
  }

  tags = merge(
    var.default_tags,
    map(
      "service_name", "ECS"
    )
  )

}

resource "aws_ecs_task_definition" "ecs_service_noalb" {
  # ECSCluster-4
  count           = "${length(var.container_noALB_def)}"
  family = "${var.ecs_name}-${lookup(var.container_noALB_def[count.index], "name")}"
  cpu = "${lookup(var.container_noALB_def[count.index], "cpu")}"
  memory = "${lookup(var.container_noALB_def[count.index], "memory")}"
  task_role_arn = "arn:aws:iam::945116902499:role/ecsTaskExecutionRole"
  execution_role_arn = "arn:aws:iam::945116902499:role/ecsTaskExecutionRole"
  container_definitions = "${data.template_file.ecs-tasks-noalb[count.index].rendered}"

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.os-type==${lookup(var.container_noALB_def[count.index], "os_type")}"
  }

  tags = merge(
    var.default_tags,
    map(
      "service_name", "ECS"
    )
  )

}

data "template_file" "ecs-tasks" {
  # ECSCluster-5
  count    = "${length(var.container_def)}"
  template = "${file("task-definitions/${lookup(var.container_def[count.index], "name")}.json")}"

  vars = {
    container_name  = "${var.ecs_name}-${lookup(var.container_def[count.index], "name")}"
    Ecs_name = "${var.ecs_name}"
    myregion = "${var.region_name}"
    project_name = "${var.default_tags["project_name"]}"
    client_name  = "${var.default_tags["client_name"]}"
  }
}

data "template_file" "ecs-tasks-noalb" {
  # ECSCluster-6
  count    = "${length(var.container_noALB_def)}"
  template = "${file("task-definitions/${lookup(var.container_noALB_def[count.index], "name")}.json")}"

  vars = {
    container_name  = "${var.ecs_name}-${lookup(var.container_noALB_def[count.index], "name")}"
    Ecs_name = "${var.ecs_name}"
    myregion = "${var.region_name}"
    project_name = "${var.default_tags["project_name"]}"
    client_name  = "${var.default_tags["client_name"]}"
  }
}

resource "aws_iam_role_policy_attachment" "ecs-service-attach" {
  # ECSCluster-7
  role       = "${var.aws_iam_ecs_service_role}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}
