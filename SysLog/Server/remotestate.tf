terraform {
  backend "s3" {
    profile = "eh_adv_aws_main_build"
    bucket  = "main-terraform-backend-us-east-1"
    key     = "tfstate/computer/Syslog_Server_Main_Prod_Linux_AZ-A/terraform.tfstate"
    region  = "us-east-1"
    encrypt = "true"
  }
}
