provider "aws" {
  region = "us-east-1"
  version = "~> 2.7"
}

terraform {
  required_version = ">= 0.11.7"

  backend "s3" {
    bucket = "${bucket}"
    key = "${key}"
    region = "${region}"
    encrypt = "true"
  }
}

