region_name        = "us-east-1"

vpc_name     = [ "Main_Prod_DMZ_VPC" ]
subnet_names = [ "Main_Prod_DMZ_AZ-A", "Main_Prod_DMZ_AZ-B" ]

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
  client_name      = "Shared"
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
