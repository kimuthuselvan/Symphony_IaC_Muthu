region_name = "us-east-1"

ecs_name = "Kan-Sym-PRD-Srv"

#vpc_name        = "vpc-07d6e088e8c0ac938"    ## Kansas_Prod_DMZ_VPC 
#subnet_name_az1 = "subnet-002070de1ac1134d5" ## Kansas_Prod_DMZ_AZ-A
#subnet_name_az2 = "subnet-03248a90e3e0be171" ## Kansas_Prod_DMZ_AZ-B 
#sg_name         = "sg-07c8f0478fc628959"     ## Kansas_Prod_DMZ_VPC_All_Open_SG

vpc_name         = "vpc-0a24350eb9334f4cf"    ## Kansas_Prod_App_VPC
subnet_name_az1  = "subnet-0f52b88b7e012eca0" ## Kansas_Prod_App_AZ-A
subnet_name_az2  = "subnet-06899ed146379aee3" ## Kansas_Prod_App_AZ-B
sg_name          = "sg-0ed4708e9c584d19a"     ## Kansas_Prod_App_VPC_All_Open_SG

keypair_name = "Kansas-PRD-ECS-Key"
instance_type = "t3.medium"
no_of_instance = "1"
max_instance_size = "4"
min_instance_size = "1"
desired_capacity = "1"

## First ASG default
ami_id = "ami-00afc256a955c31b5" ## Amazon Linux 2 AMI for ECS
user_data_file = "ecs-cluster_linux.tpl"
running-os = "Linux"
#container_task_file = "task-definitions/TraceService_Linux.json"

## Second ASG on demand
second_asg = true
ami_id_2 = "ami-0eb7093437bbdc227" ## Windows 2019 AMI for ECS
user_data_file_2 = "ecs-cluster_windows.tpl"
running-os_2 = "Windows"
#container_task_file_2 = "task-definitions/WebApp_Windows.json"

## Container definitions here
container_default_task = 4
container_def = [
  {
    name = "auditevents"
    searchpath = "/api/auditevents/healthz"
    successcode = 200
    listener_rule = "/api/auditevents*"
    os_type = "linux"
    cpu = 512
    memory = 512
  },
  {
    name = "cklscrawler"
    searchpath = "/api/checklistcrawler/healthz"
    successcode = 200
    listener_rule = "/api/checklistcrawler*"
    os_type = "linux"
    cpu = 512
    memory = 512
  },
  {
    name = "dataaudit"
    searchpath = "/api/dataaudit/healthz"
    successcode = 200
    listener_rule = "/api/dataaudit*"
    os_type = "linux"
    cpu = 512
    memory = 512
  },
  {
    name = "esindexer"
    searchpath = "/api/elasticsearchindexer/healthz"
    successcode = 200
    listener_rule = "/api/elasticsearchindexer*"
    os_type = "linux"
    cpu = 512
    memory = 512
  },
  {
    name = "jobs"
    searchpath = "/Account/Login?ReturnUrl=%2Fjobs"
    successcode = 200
    listener_rule = "default"
    os_type = "windows"
    cpu = 1024
    memory = 1024
  }

]
container_port = 443
container_desired_count = 1
aws_alb_protocol = "HTTPS"
alb_list_port = 443
alb_target_port = 443

aws_iam_ecs_service_role = "ecs-service-role"
aws_iam_ecs_ec2_role = "ecs-ec2-role"
aws_iam_role_policy = "ecs-ec2-role-policy"

# Tags
project_name = "Symphony"
client_name = "Kansas"
environment_name = "UAT"
zone_name = "Trusted"
linux_name = "CentOS 7"
windows_name = "Windows 2019"

