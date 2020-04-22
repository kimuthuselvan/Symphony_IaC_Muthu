region_name = "us-east-1"

ecs_name = "Sym-Kan-PRD-WebApp"

vpc_name        = [ "Kansas_Prod_DMZ_VPC" ]
subnet_names    = [ "Kansas_Prod_DMZ_AZ-A", "Kansas_Prod_DMZ_AZ-B" ]

instance_type = "t3.medium"
no_of_instance = "1"
max_instance_size = "4"
min_instance_size = "2"
desired_capacity = "2"
domain_name = "*.sym-advantasure.com"
sns_name    = "usage-notifications-symphony"


## First ASG default
ami_id = "ami-00afc256a955c31b5" ## Amazon Linux 2 AMI for ECS
user_data_file = "ecs-cluster_linux.tpl"
running-os = "Linux"

## Second ASG on demand
second_asg = true
ami_id_2 = "ami-0eefaa2ef616b28bf" ## Windows 2019 AMI for ECS
user_data_file_2 = "ecs-cluster_windows.tpl"
running-os_2 = "Windows"

## Container definitions here
container_default_task = 1
container_def = [
  {
    name = "trace"
    searchpath = "/traceapi/healthz"
    successcode = 200
    listener_rule = "/traceapi*"
    os_type = "linux"
    cpu = 512
    memory = 1025
  },
  {
    name = "webapp"
    searchpath = "/"
    successcode = 302
    listener_rule = "default"
    os_type = "windows"
    cpu = 1024
    memory = 2048
  }

]

container_noALB_def = [
  {
    name = "sqlexecutor"
    searchpath = "NA"
    successcode = "NA"
    listener_rule = "NONE"
    os_type = "windows"
    cpu = 1024
    memory = 1024
  },

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
default_tags = {
  client_name = "Kansas"
  project_name = "Symphony"
  service_role = "ECS"
  environment_name = "Production"
  backup_frequency = "Never"
  billing_type = "Client"
  security_zone = "DMZ"
  app_version = "3.4.0"
  backup_vault = "-N/A-"
}

# Enable and Disable monitoring for services
# 1 - enable, 0 - disable
ec2_enable_monitoring = 1
cpu_threshold = 70
