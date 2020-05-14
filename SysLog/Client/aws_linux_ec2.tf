resource "aws_security_group" "security_group" {
  provider    = aws.eh_adv_aws_main
  name        = "${var.instance_name}-SG"
  description = "Security Group for ${var.instance_name}"
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

    tags = var.default_tags
}

resource "aws_instance" "syslog" {
  provider        = aws.eh_adv_aws_main
  ami             = data.aws_ami.amazon-linux-2.id
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = [aws_security_group.security_group.id]
  subnet_id       = data.aws_subnet.subnet_id.id
  user_data       = var.user_data_file

  root_block_device {
    encrypted = true
  }

  volume_tags = {
    Name = var.instance_name
  }

  tags = var.default_tags
}
