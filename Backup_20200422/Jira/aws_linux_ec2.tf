resource "aws_security_group" "security_group" {
  name        = "${var.server_name}-SG"
  description = "Security Group for ${var.server_name}"
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

resource "aws_instance" "jira" {
  ami             = "ami-0d97579aa49c5ca50"
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = [aws_security_group.security_group.id]
  subnet_id       = data.aws_subnet.subnet_id.id
  user_data       = var.user_data_file

  root_block_device {
    encrypted = true
  }

  volume_tags = {
    Name = "${var.server_name}"
  }

  tags = var.default_tags
}

output "instance_id" {
  value = aws_instance.jira.id
}

output "instance_dns_name" {
  value = aws_instance.jira.private_dns
}

output "instance_private_ip" {
  value = aws_instance.jira.private_ip
}
