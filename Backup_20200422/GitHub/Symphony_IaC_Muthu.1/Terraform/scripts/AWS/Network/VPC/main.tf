provider "aws" {
  region = "${var.region_name}"
  version = "~> 2.7"
}

terraform {
  backend "s3" {}
  #required_version = ">= 0.11.7"
}

resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  instance_tenancy = "default"

  tags = {
    Name = "${var.vpc_name}"
    Project = "${var.project_name}"
    Organization = "${var.organization_name}"
    Client = "${var.client_name}"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = "${aws_vpc.main.id}"
  #name = "${var.vpc_name}_Open_All_SG"
  #description  = "Default Security Group for VPC: ${var.vpc_name} - All Ports open"

  ingress {
    protocol = "-1"
    self = true
    from_port = 0
    to_port = 0
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "${var.vpc_name}_Open_All_SG"
    Project = "${var.project_name}"
    Organization = "${var.organization_name}"
    Client = "${var.client_name}"
  }
}

resource "aws_security_group" "linux_web_sg" {
  vpc_id       = "${aws_vpc.main.id}"
  name         = "${var.vpc_name}_Linux_Web_SG"
  description  = "Security Group for Linux - SSH and Web Ports open"
  
  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "${var.vpc_name}_Linux_Web_SG"
    Project = "${var.project_name}"
    Organization = "${var.organization_name}"
    Client = "${var.client_name}"
  }
}

resource "aws_security_group" "windows_web_sg" {
  vpc_id       = "${aws_vpc.main.id}"
  name         = "${var.vpc_name}_Windows_Web_SG"
  description  = "Security Group for Windows - RDP and Web Ports open"

  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "${var.vpc_name}_Windows_Web_SG"
    Project = "${var.project_name}"
    Organization = "${var.organization_name}"
    Client = "${var.client_name}"
  }
}

