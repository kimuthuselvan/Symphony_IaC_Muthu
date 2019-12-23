region = "us-east-1"
vpc_name = "AHS_Prod_Data_VPC"
subnet_name = "AHS_Prod_Data_AZ-B"
subnet_cidr = "10.126.192.32/27"
subnet_az = "us-east-1b"

tag_name = "AHS_Prod_Data_AZ-B"
tag_project = "Symphony"
tag_organization = "Advantasure Inc."
tag_clietn = "AHS"

tfstate_backend = "symphony-ahs-backend-tfstate-us-east-1"
tfstate_path = "tfstate/Networking/AHS_Prod_Data_VPC/AHS_Prod_Data_AZ-B/AHS_Prod_Data_AZ-B.tfstate"
