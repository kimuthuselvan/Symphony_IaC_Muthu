ecs_name       = "Sym-Kan-UAT-WebApp"
alb_dns_name   = "internal-Sym-Kan-UAT-WebApp-ELB-959311973.us-east-1.elb.amazonaws.com"  # to be input from previous terraform output
region_name    = "us-east-1"  
vpc_name       = "vpc-0b91f680b7588b87f" ## Security_Ext_FW_Internet_VPC
cron_name      = "cron-minute-lambda"
cron_arn       = "arn:aws:events:us-east-1:660751646273:rule/cron-minute-lambda"
#iam_role_name  = "lambdaFunction-NLB-to-ALB-role"
iam_role_arn = "arn:aws:iam::660751646273:role/lambdaFunction-NLB-to-ALB-role"
subnet_name_az1 = "subnet-0f14641bf3d02ce57" ## Security_Ext_FW_Internet_AZ-A
subnet_name_az2 = "subnet-0a7893a240ead65f7" ## Security_Ext_FW_Internet_AZ-B
subnet_cidr_az1 = "10.126.132.0/26"
subnet_cidr_az2 = "10.126.132.64/26"

