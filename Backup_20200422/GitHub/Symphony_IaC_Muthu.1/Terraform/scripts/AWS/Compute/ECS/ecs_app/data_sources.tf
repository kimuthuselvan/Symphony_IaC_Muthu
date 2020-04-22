# Remote state
data "terraform_remote_state" "ecs_cluster" {
  backend = "s3"

  config  = {
    bucket = "sathish-packt-terraform-backbone-test-us-east-1"
    key    = "test/ecs_cluster"
    region = "${var.region}"
  }
}

 data "terraform_remote_state" "rds" {
   backend = "s3"

   config  = {
     bucket = "sathish-packt-terraform-backbone-test-us-east-1"
     key    = "test/rds"
     region = "${var.region}"
   }
 }

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config  = {
    bucket = "sathish-packt-terraform-backbone-test-us-east-1"
    key    = "test/vpc"
    region = "${var.region}"
  }
}
