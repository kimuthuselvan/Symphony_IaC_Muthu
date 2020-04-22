region_name = "us-east-1"

vpc_name     = [ "Main_Prod_App_VPC" ]
subnet_name  = [ "Main_Prod_App_AZ-A" ]
#subnets_name = [ "Main_Prod_App_AZ-A", "Main_Prod_App_AZ-B" ]
#azs_name     = [ "AZ-A", "AZ-B" ]

server_name    = "Symphony-Grafana-Linux"
key_name       = "Symphony-Grafana-Linux-Key"
instance_type  = "t2.micro"
user_data_file = "aws_linux_ec2.tpl"

default_tags = {
  Name             = "Symphony-Grafana-Linux"
  client_name      = "Shared"
  project_name     = "Symphony"
  service_name     = "EC2"
  service_role     = "AWS Dashboard"
  environment_name = "Production"
  backup_frequency = "Never"
  billing_type     = "Client"
  security_zone    = "Trusted"
  app_version      = "1.0"
  backup_vault     = "-N/A-"
  os_type          = "Linux"
  os_name          = "Amazon Linux 2"
}

