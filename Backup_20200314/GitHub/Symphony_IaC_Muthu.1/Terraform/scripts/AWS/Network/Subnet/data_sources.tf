# Remote state
data "terraform_remote_state" "vpc" {
  backend = "s3"

#  config  = {
#    bucket = "${bucket_name}"
#    key    = "${vpc_tfstate_file}"
#    region = "${region}"
#  }
#}

  config  = {
    bucket = "test-star-dot-star"
    key = "tfstate/vpc/AHS_Prod_DMZ_VPC/terraform.tfstate"
    region = "us-east-1"
  }
}
 
