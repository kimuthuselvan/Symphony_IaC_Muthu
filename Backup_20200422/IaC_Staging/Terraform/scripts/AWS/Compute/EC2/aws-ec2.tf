###============================================================================
### Script name: aws-ec2.tf
### Script type: Terraform script
### Discription: To create AWS Subnet only for given CIDR and this will not
###              create Subnets, Security Group, ACL ... etc.
### Note: As of now this script will support for AWS.
### Version: 1.0					Date: 2019-11-09
### Author/Developer: Muthuselvan I. Kangeya
### Reviewed:
###============================================================================
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ubuntu-ec2" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t3.medium"
  subnet_id = "${data.terraform_remote_state.subnet.outputs.private_subnet_id}"
  key_name = "test_linux_key_1"

  tags = {
    Name = "${var.ec2_name}"
    Project = "${var.project_name}"
    Organization = "${var.organization_name}"
    Client = "${var.client_name}"
  }

}

###============================================================================
### End
###============================================================================
