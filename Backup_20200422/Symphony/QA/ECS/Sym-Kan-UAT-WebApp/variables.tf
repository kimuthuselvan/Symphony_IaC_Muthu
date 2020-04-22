#variable "aws_access_key_id" {}
#variable "aws_secret_access_key" {}
variable "region_name" {}
variable "vpc_name" {}
variable "ecs_name" {}
variable "subnet_names" {}
#variable "key_name" {}
variable "instance_type" {}
variable "no_of_instance" {}
variable "max_instance_size" {}
variable "min_instance_size" {}
variable "desired_capacity" {}
variable "ami_id" {}
variable "user_data_file" {}
variable "running-os" {}
variable "second_asg" {}
variable "ami_id_2" {}
variable "user_data_file_2" {}
variable "running-os_2" {}
variable "container_desired_count" {}
variable "aws_alb_protocol" {}
variable "alb_list_port" {}
variable "aws_iam_ecs_service_role" {}
variable "aws_iam_ecs_ec2_role" {}
variable "aws_iam_role_policy" {}
variable "container_def" {}
variable "container_noALB_def" {}
variable "container_default_task" {}
variable "container_port" {}
variable "alb_target_port" {}
variable "certificate_arn" {}

## Tags
variable "default_tags" {}

## for cloudwatch alarm
variable "ec2_enable_monitoring" {}
variable "emails" {}
variable "cpu_threshold" {}
