### vpc_id         = "vpc-0b2eba5d72c599770"     ## Main_Prod_App_VPC
### subnet_id_1a   = "subnet-0c2bbd3fc6aa29e0d"  ## Main_Prod_App_AZ-A
### subnet_id_1b   = "subnet-0b89a4615bf0fc2b7"  ## Main_Prod_App_AZ-B
### sg_id          = "sg-04b4c593629f2e84c"      ## Main_Prod_App_VPC_All_Open_SG
### linux_ami_id   = "ami-062f7200baf2fa504"     ## Amazon Linux 2 AMI
### windows_ami_id = "ami-02daaf23b3890d162"     ## Windows 2016

region_name = "us-east-1"

vpc_id    = "vpc-0b2eba5d72c599770"
subnet_id = ["subnet-0c2bbd3fc6aa29e0d"]
#subnet_id = ["subnet-0c2bbd3fc6aa29e0d", "subnet-0b89a4615bf0fc2b7"]
sg_id     = "sg-04b4c593629f2e84c"

key_name  = "symphony_eft_prod_key"
instance_type = "t3.medium"

#create_lb = false

efs_dns_name = "fs-3f64a7bf.efs.us-east-1.amazonaws.com"

project_name = "Symphony"
client_name  = "Shared"
application_name = "EFT"
environment_name = "Development"
linux_name = "Amazon Linux 2"
linux_type = "Linux"
windows_name = "Windows 2016"
windows_type = "Windows"

