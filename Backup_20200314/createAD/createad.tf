provider "aws" {
  region     = var.region_name
}

resource "aws_directory_service_directory" "my_simplead" {
  type     = "SimpleAD"
  name     = var.domain_name
  short_name = var.short_name
  size     = var.AD_size
  password = var.admin_password

  vpc_settings {
    vpc_id     =  var.vpc_id
    subnet_ids =  var.subnet_ids
  }
}
