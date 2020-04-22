### vpc_id         = "vpc-0e939a73aed858b36"     ## Security_VPC
### subnet_id_1a   = "subnet-0af9523ff318d0607"  ## Security_AZ-A
### subnet_id_1b   = "subnet-04bd184288a226fb7"  ## Secuirty_AZ-B
### sg_id          = "sg-04b4c593629f2e84c"      ## Main_Prod_App_VPC_All_Open_SG

region_name = "us-east-1"

vpc_id      = "vpc-0e939a73aed858b36"
subnet_id   = [ "subnet-0af9523ff318d0607", "subnet-04bd184288a226fb7" ] 
subnet_name = [ "AZ-A", "AZ-B" ]

key_name      = "Symphony_WebServer_Production_Linux-Key"
instance_type = "t2.micro"
#volume_type = "gp2"
#volume_size = 100

#join_to_ad    = true ## true or false

#require_ASG       = false ## true or false
#min_instance_size = 1
#desired_capacity  = 1
#max_instance_size = 2
#user_data_file    = "linux_ec2.tpl"

default_tags = {
  project_name     = "Symphony"
  client_name      = "Shared"
  application_name = "WebServer"
  environment_name = "Production"
  security_zone    = "DMZ"
  os_name          = "Amazon Linux 2"
  os_type          = "Linux"
}

