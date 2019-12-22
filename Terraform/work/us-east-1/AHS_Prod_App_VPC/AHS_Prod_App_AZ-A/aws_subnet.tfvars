region = "us-east-1"
vpc_name = "AHS_Prod_App_VPC"
subnet_name = "AHS_Prod_App_AZ-A"
subnet_cidr = "10.126.192.0/27"
subnet_az = "us-east-1a"

tag_name = "AHS_Prod_App_AZ-A"
tag_project = "Symphony"
tag_organization = "Advantasure Inc."
tag_clietn = "AHS"

tfstate_backend = "symphony-ahs-backend-tfstate-us-east-1"
tfstate_path = "tfstate/Networking/AHS_Prod_App_VPC/AHS_Prod_App_AZ-A/AHS_Prod_App_AZ-A.tfstate"
