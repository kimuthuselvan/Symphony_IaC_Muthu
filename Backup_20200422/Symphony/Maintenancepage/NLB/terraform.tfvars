ecs_name       = "Symphony-MaintenancePage"
## To be update ALB DNS Name from Sym-Kan-UAT-WebApp ##
alb_dns_name   = "internal-Symphony-MaintenancePage-ALB-182980931.us-east-1.elb.amazonaws.com"
region_name    = "us-east-1"  
vpc_name       = [ "Security_Ext_FW_Internet_VPC" ]
subnet_names   = [ "Security_Ext_FW_Internet_AZ-A", "Security_Ext_FW_Internet_AZ-B" ]

subnet_cidr_az1 = "10.126.132.128/26"
subnet_cidr_az2 = "10.126.132.192/26"

# Tags
default_tags = {
  client_name = "Kansas"
  project_name = "Symphony"
  service_role = "ECS"
  environment_name = "UAT"
  backup_frequency = "Never"
  billing_type = "Client"
  security_zone = "DMZ"
  app_version = "3.4.0"
}

