resource "aws_security_group" "security_group" {
  # ECSSG-1
  name        = "${var.ecs_name}-SG"
  description = "Security Group for ECS Security Group"
  vpc_id      = data.aws_vpc.vpc_id.id

  ingress {
    protocol  = "-1"
    from_port = 0
    to_port   = 0
    cidr_blocks = [ "0.0.0.0/0" ]
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
      "service_name", "SG"
    )
  )

}
