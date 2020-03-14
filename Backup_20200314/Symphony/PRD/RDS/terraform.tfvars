region_name = "us-east-1"

vpc_id = "vpc-0f8dffb441db4a3b7" ## Kansas_Prod_Data_VPC
subnet_ids = ["subnet-0f4e8b039336531a1", "subnet-01990fdba952e6896"] ## Kansas_Prod_Data_AZ-A, Kansas_Prod_Data_AZ-B

cidr_ip_1 = "10.126.112.0/23" ## VDI - Admin Full
cidr_ip_2 = "10.126.116.0/23" ## VDI - Dev Full
cidr_ip_3 = "10.126.132.128/25" ## Kansas_UAT_DMZ_VPC
cidr_ip_4 = "10.126.196.192/26" ## Kansas_UAT_Data_VPC

name_prefix = "symkanprddb"
ca_cert_identifier = "rds-ca-2019"
tag_name_prefix = "Symphony_Kansas_Production_DB"
project = "Symphony"
environment = "Production"
client = "Kansas"
zone = "Trusted"
server = "MS-SQL Server 14.00"
