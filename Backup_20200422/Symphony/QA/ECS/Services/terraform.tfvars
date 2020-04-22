region_name = "us-east-1"

ecs_name = "Sym-Kan-UAT-Srv"

vpc_name        = "vpc-06c13c9b668bf9b10"    ## Kansas_UAT_App_VPC 
subnet_name_az1 = "subnet-0141b22d927d3f2a3" ## Kansas_UAT_App_AZ-A
subnet_name_az2 = "subnet-0472ff3f6f5061d0a" ## Kansas_UAT_App_AZ-B 
sg_name         = "sg-09658cb46dea37e24"     ## Kansas_UAT_App_VPC_Open_All_SG

key_name = "Sym-Kan-UAT-Srv-Key"
instance_type = "t3.medium"
no_of_instance = "1"
max_instance_size = "4"
min_instance_size = "2"
desired_capacity = "2"

certificate_arn = "arn:aws:acm:us-east-1:945116902499:certificate/8482eb94-d63e-42eb-b2dd-15b7fd3c40ec"

## First ASG default
ami_id = "ami-00afc256a955c31b5" ## Amazon Linux 2 AMI for ECS
user_data_file = "ecs-cluster_linux.tpl"
running-os = "Linux"
#container_task_file = "task-definitions/TraceService_Linux.json"

## Second ASG on demand
second_asg = true
ami_id_2 = "ami-0eefaa2ef616b28bf" ## Windows 2019 AMI for ECS
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

container_noALB_def = [

]

container_port = 443
container_desired_count = 2
aws_alb_protocol = "HTTPS"
alb_list_port = 443
alb_target_port = 443

aws_iam_ecs_service_role = "ecs-service-role"
aws_iam_ecs_ec2_role = "ecs-ec2-role"
aws_iam_role_policy = "ecs-ec2-role-policy"

# Tags
client_name = "Kansas"
project_name = "Symphony"
service_name = "EC2"
service_role = "ECS"
environment_name = "Production"
backup_frequency = "Never"
billing_type = "Client"
security_zone = "Trusted"
app_version = "3.4.0"
backup_vault = "-N/A-"

# Enable and Disable monitoring for services
# 1 - enable, 0 - disable
ec2_enable_monitoring = 1
cpu_threshold = 70
emails = [ "EHIAWSSUPPORT@hcl.com", "michael.lindskov@emergentholdingsinc.com", "Michael.Barron@advantasure.com", "symphony-error-notify-qa@advantasure.com" ]
