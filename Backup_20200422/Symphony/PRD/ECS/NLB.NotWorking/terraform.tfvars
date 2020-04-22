## To be input from previous terraform output for alb_dns_name ##
region_name     = "us-east-1"
 
vpc_name        = "vpc-0b91f680b7588b87f"    ## Security_Ext_FW_Internet_VPC
subnet_name_az1 = "subnet-0f14641bf3d02ce57" ## Security_Ext_FW_Internet_AZ-A
subnet_name_az2 = "subnet-0a7893a240ead65f7" ## Security_Ext_FW_Internet_AZ-B

ecs_name        = "Sym-Kan-PRD-WebApp"
alb_dns_name    = "internal-Sym-Kan-PRD-WebApp-ELB-1688869804.us-east-1.elb.amazonaws.com"
cron_arn        = "arn:aws:events:us-east-1:660751646273:rule/cron-minute-lambda"
#iam_role_arn    = "arn:aws:iam::660751646273:role/lambdaFunction-NLB-to-ALB-role"
subnet_cidr_az1 = "10.126.132.0/26"
subnet_cidr_az2 = "10.126.132.64/26"

default_tags = {
  client_name = "Kansas"
  project_name = "Symphony"
  service_name = "NLB"
  service_role = "ALB2NLB"
  environment_name = "Production"
  backup_frequency = "Never"
  billing_type = "Client"
  security_zone = "DMZ"
  app_version = "1.0"
  backup_vault = "-N/A-"
}

