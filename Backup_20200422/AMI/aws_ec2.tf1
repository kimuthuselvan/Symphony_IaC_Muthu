provider "aws" {
  region = var.region_name
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners = var.owners

  filter {
    name   = "owner-alias"
    values = var.filter_image_owner_alias
  }

  filter {
    name   = "name"
    values = var.filter_image_location
  }
}

resource "aws_instance" "amazon_linux" {
  ami             = data.aws_ami.amazon-linux-2.id
  instance_type   = var.instance_type
  key_name        = var.key_name
  subnet_id       = var.subnet_id
  security_groups = ["${var.sg_id}"]

  root_block_device {
    encrypted = true
  }

  volume_tags = {
    Name = var.ec2_name
  }

  tags = {
    Name = var.ec2_name
  }
}
