provider "aws" {
  region = var.region_name
}

terraform {
  backend "s3" {
    bucket  = "main-terraform-backend-us-east-1"
    key     = "tfstate/network/Main_DMZ_Prod_VPC"
    region  = "us-east-1"
    encrypt = "true"
  }
}
