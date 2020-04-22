region_name        = "us-east-1"

#vpc_id      = "vpc-075b5264a3b4c3462" ## Security_DMZ_VPC
#subnet_name = [ "Security_DMZ_AZ-A", "Security_DMZ_AZ-B" ]
#az_name     = [ "AZ-A", "AZ-B" ]
#subnet_id   = [ "subnet-09ee0d6653ec34099", "subnet-0512fabde0e25b0db" ]

#vpc_name       = [ "Security_Ext_FW_Internet_VPC" ]
#subnet_names   = [ "Security_Ext_FW_Internet_AZ-A", "Security_Ext_FW_Internet_AZ-B" ]
vpc_name     = [ "Kansas_UAT_DMZ_VPC" ]
subnet_names = [ "Kansas_UAT_DMZ_AZ-A", "Kansas_UAT_DMZ_AZ-B" ]

key_name          = "Symphony-MaintenancePage-Linux-Key"
instance_type     = "t2.micro"
min_instance_size = 2
desired_capacity  = 2
max_instance_size = 3
user_data_file    = "setup_apache_maintenancepage.tpl"

aws_alb_protocol    = "HTTPS"
alb_list_port       = 443
alb_target_port     = 80
alb_target_protocol = "HTTP"
#certificate_arn     = "arn:aws:acm:us-east-1:660751646273:certificate/e05473e0-e99b-4abf-bc4c-18317026c094"
domain_name         = "*.sym-advantasure.com"

default_tags = {
  client_name      = "Kansas"
  project_name     = "Symphony"
  service_name     = "EC2"
  service_role     = "MaintenancePage"
  environment_name = "Production"
  backup_frequency = "Never"
  billing_type     = "Client"
  security_zone    = "DMZ"
  app_version      = "1.0"
  backup_vault     = "-N/A-"
  os_type          = "Linux"
  os_name          = "Amazon Linux 2"
}
