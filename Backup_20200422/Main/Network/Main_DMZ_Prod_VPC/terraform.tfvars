region_name = "us-east-1"

vpc_name       = "Main_Prod_DMZ_VPC"
vpc_cidr_block = "10.126.4.0/24"

subnets_name   = [ "Main_Prod_DMZ_AZ-A", "Main_Prod_DMZ_AZ-B" ]
subnets_cidr_block = [ "10.126.4.0/25", "10.126.4.128/25" ]
azs = [ "us-east-1a", "us-east-1b" ]

project_name = "Symphony"
client_name  = "Shared"
organization_name = "Advantasure"
aws_account  = "EH_Adv_Main"

#default_tags = {
#  client_name   = "Main"
#  project_name  = "Symphony"
#  security_zone = "DMZ"
#}

