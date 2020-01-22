region_name = "us-east-1"

vpc_id = "vpc-0b2eba5d72c599770"       ## Main_Prod_App_VPC
subnet_id = "subnet-0c2bbd3fc6aa29e0d" ## Main_Prod_App_AZ-A
#subnet_id = ["subnet-0c2bbd3fc6aa29e0d", "subnet-0b89a4615bf0fc2b7"]

#subnet_id = ["Main_Prod_App_AZ-A", "Main_Prod_App_AZ-B"] ## subnet-0c2bbd3fc6aa29e0d,subnet-0b89a4615bf0fc2b7
#subnet_id = ["subnet-0c2bbd3fc6aa29e0d", "subnet-0b89a4615bf0fc2b7"]
#linux_ami_id = "ami-062f7200baf2fa504"                   ## Amazon Linux 2 AMI
#windows_ami_id = "ami-02daaf23b3890d162"                 ## Windows 2016

key_name = "symphony_eft_prod_key"
sg_id = "sg-04b4c593629f2e84c"          ## Main_Prod_App_VPC_All_Open_SG
instance_type = "t3.medium"

project_name = "Symphony"
client_name = "Shared"
application_name = "EFT"
environment_name = "Production"
linux_name = "Amazon Linux 2"
linux_type = "Linux"
windows_name = "Windows 2016"
windows_type = "Windows"

#user_data_file = "linux_ec2.tpl"
