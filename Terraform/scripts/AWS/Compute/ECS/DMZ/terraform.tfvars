region_name = "us-east-1"

ecs_name = "Kan-Sym-UAT-WebApp"
#ecs_name = "Kan-UAT-WebApp"

#vpc_name        = "vpc-06c13c9b668bf9b10"    ## Kansas_UAT_App_VPC
#subnet_name_az1 = "subnet-0141b22d927d3f2a3" ## Kansas_UAT_App_AZ-A
#subnet_name_az2 = "subnet-0472ff3f6f5061d0a" ## Kansas_UAT_App_AZ-B
#sg_name         = "sg-09658cb46dea37e24"     ## Kansas_UAT_App_VPC_Open_All_SG

vpc_name         = "vpc-069d202f6c6abf29a"    ## Kansas_UAT_DMZ_VPC
subnet_name_az1  = "subnet-0c4816f7842153167" ## Kansas_UAT_DMZ_AZ-A
subnet_name_az2  = "subnet-045f15dc2d848718a" ## Kansas_UAT_DMZ_AZ-B
sg_name          = "sg-09a4c12052a8fa6c6"     ## Kansas_UAT_DMZ_VPC_Open_All_SG

#vpc_name = "vpc-0723950c0008a5b6b"
#subnet_name_az1 = "subnet-0d670818706131191"
#subnet_name_az2 = "subnet-053362645abd72e3e"
#sg_name = "sg-0f2cd5800f1ecfcc7"

keypair_name = "Kansas-UAT-ECS-Key"
#keypair_name = "Samba_Linux"
instance_type = "t3.medium"
no_of_instance = "2"
max_instance_size = "4"
min_instance_size = "2"
desired_capacity = "2"

## First ASG default
ami_id = "ami-00afc256a955c31b5" ## Amazon Linux 2 AMI for ECS
user_data_file = "ecs-cluster_linux.tpl"
running-os = "Linux"
container_task_file = "task-definitions/TraceService_Linux.json"

## Second ASG on demand
second_asg = true
ami_id_2 = "ami-0eb7093437bbdc227" ## Windows 2019 AMI for ECS
user_data_file_2 = "ecs-cluster_windows.tpl"
running-os_2 = "Windows"
container_task_file_2 = "task-definitions/WebApp_Windows.json"

##
container_def = [
  {
    name = "trace"
    searchpath = "/traceapi/healthz"
    successcode = 200
    os_type = "linux"
    cpu = 512
    memory = 1024
  },
  {
    name = "webapp"
    searchpath = "/"
    successcode = 302
    os_type = "windows"
    cpu = 1024
    memory = 2048
  }
]
container_port = 443
container_desired_count = 2
aws_alb_protocol = "HTTPS"
alb_list_port = 443
alb_target_port = 443

#container_desired_count = 2
#aws_alb_protocol = "HTTPS"
#alb_list_port = 443
#alb_target_port = 443
aws_iam_ecs_service_role = "ecs-service-role"
aws_iam_ecs_ec2_role = "ecs-ec2-role"
aws_iam_role_policy = "ecs-ec2-role-policy"

# Tags
project_name = "Symphony"
client_name = "Kansas"
environment_name = "UAT"
zone_name = "DMZ"
linux_name = "CentOS 7"
windows_name = "Windows 2019"

