###============================================================================
### Script name: aws-subnet.tf
### Script type: Terraform script
### Discription: To create AWS Subnet only for given CIDR and this will not
###              create Subnets, Security Group, ACL ... etc.
### Note: As of now this script will support for AWS.
### Version: 1.0					Date: 2019-11-09
### Author/Developer: Muthuselvan I. Kangeya
### Reviewed:
###============================================================================
resource "aws_subnet" "private" {
  cidr_block = "${var.subnet_cidr}"
  #vpc_id = "${aws_vpc.main.id}"
  vpc_id = "${data.terraform_remote_state.vpc.outputs.vpc_id}"
  availability_zone = "${var.subnet_az}"

  tags = {
    Name = "${var.subnet_name}"
    Project = "${var.project_name}"
    Organization = "${var.organization_name}"
    Client = "${var.client_name}"
  }
}

###============================================================================
### End
###============================================================================
