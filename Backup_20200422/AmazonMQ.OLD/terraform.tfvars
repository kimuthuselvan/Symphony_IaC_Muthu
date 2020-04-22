# vpc_id          = "vpc-0834143b1d7b2b267"    # Kansas_UAT_Data_VPC
# subnet_id_1a    = "subnet-04c3c2e8144e0ed14" # Kansas_UAT_Data_AZ-A
# subnet_id_1b    = "subnet-03febb9b730d65b21" # Kansas_UAT_Data_AZ-B
# security_groups = "sg-0b7a44a78f13d2520"     # Kansas_UAT_Data_VPC_Open_All_SG

broker_name = "Symphony-Kansas-UAT-ActiveMQ"
aws_mq_config_name = "amazonmqcfg"

subnet_ids = ["subnet-04c3c2e8144e0ed14", "subnet-03febb9b730d65b21"]
security_groups = ""

engine_type = "ActiveMQ"
engine_version = "5.15.9"
instance_type = "mq.t2.micro"

tag_name = "Symphony_Kansas_UAT_ActiveMQ"
project_name = "Symphony"
client_name = "Kansas"
environment_name = "UAT"
network_zone = "Trusted"
username = "amazonmquat"
password = "_amaz0nmquat_"
