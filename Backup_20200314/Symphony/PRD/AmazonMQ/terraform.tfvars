## vpc_id          = "vpc-0f8dffb441db4a3b7"    # Kansas_Prod_Data_VPC
## subnet_id_1a    = "subnet-0f4e8b039336531a1" # Kansas_Prod_Data_AZ-A
## subnet_id_1b    = "subnet-01990fdba952e6896" # Kansas_Prod_Data_AZ-B
## security_groups = "sg-0a33bb74467172222"     # Kansas_Prod_Data_VPC_All_Open_SG

## Broker Configuration
aws_mq_config_name = "amazonmqprdcfg"
config_description = "Symphony-Kansas-PRD-Configuration"
engine_type        = "ActiveMQ"
engine_version     = "5.15.9"
instance_type      = "mq.t2.micro"

## Broker
broker_name = "symkanmqprd"
username    = "amazonmqprd"
password    = "_Amaz0nMQPRD_"

## Network
region_name     = "us-east-1"
subnet_ids      = ["subnet-0f4e8b039336531a1", "subnet-01990fdba952e6896"]
security_groups = ["sg-0a33bb74467172222"]

## Tags
tag_name         = "Symphony_Kansas_Production_ActiveMQ"
project_name     = "Symphony"
client_name      = "Kansas"
environment_name = "Production"
zone_name        = "Trusted"
