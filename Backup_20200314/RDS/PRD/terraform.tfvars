region_name = "us-east-1"

#vpc_id = "vpc-0834143b1d7b2b267" ## Kansas_UAT_Data_VPC
#subnet_ids = ["subnet-04c3c2e8144e0ed14", "subnet-03febb9b730d65b21"] ## Kansas_UAT_Data_AZ-A, Kansas_UAT_Data_AZ-B

vpc_id = "vpc-0f8dffb441db4a3b7" ## Kansas_Prod_Data_VPC
subnet_ids = ["subnet-0f4e8b039336531a1", "subnet-01990fdba952e6896"] ## Kansas_Prod_Data_AZ-A, Kansas_Prod_Data_AZ-B

cidr_ip_1 = "10.126.112.0/23" ## VDI - Admin Full
cidr_ip_2 = "10.126.116.0/23" ## VDI - Dev Full

cidr_ip_3 = "10.126.196.64/26" ## Kansas_Prod_Data_VPC
cidr_ip_4 = "10.126.132.0/25"  ## Kansas_Prod_DMZ_VPC

#cidr_ip_3 = "10.126.132.128/25" ## Kansas_UAT_DMZ_VPC
#cidr_ip_4 = "10.126.196.192/26" ## Kansas_UAT_Data_VPC

