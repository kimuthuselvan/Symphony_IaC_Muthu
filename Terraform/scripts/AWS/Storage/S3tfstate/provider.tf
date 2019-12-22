provider "aws" {
  region = "us-east-1"
  version = "~> 2.7"
}

/*
terraform {
  required_version = ">= 0.11.7"

  backend "s3" {
    bucket = "ahs-iac-bucket-us-east-1"
    key = "tfstate/s3"
    region = "us-east-1"
    encrypt = "true"
  }
}
*/
