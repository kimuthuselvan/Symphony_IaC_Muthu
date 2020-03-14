region_name = "us-east-1"
vpc_name = "vpc-069d202f6c6abf29a"
subnet_name_az1 = "subnet-0c4816f7842153167"
subnet_name_az2 = "subnet-045f15dc2d848718a"
sg_name = "sg-09a4c12052a8fa6c6"
keypair_name = "Kansas-UAT-ECS-Key"
instance_type = "t2.micro"
#ami_id = "ami-0691744871225b70c" ## CentOS 7 AMI
ami_id = "ami-00afc256a955c31b5" ## Amazon 2 AMI
#ami_id = "ami-0eb619c2c612564b0"  ## CentOS 7 AMI with Docker
no_of_instance = "2"
ecs_name = "Symphony-Kansas-Linux-ECS"
max_instance_size = "4"
min_instance_size = "2"
desired_capacity = "2"
container_image = "httpd"
container_version = "2.4"
container_desired_count = 2
aws_alb_protocol = "HTTP"
container_Port = 80
host_Port = 80
aws_iam_ecs_service_role = "ecs-service-role"
aws_iam_ecs_ec2_role = "ecs-ec2-role"
aws_iam_role_policy = "ecs-ec2-role-policy"
project_name = "Symphony"
client_name = "Kansas"
environment_name = "UAT-DMZ"

