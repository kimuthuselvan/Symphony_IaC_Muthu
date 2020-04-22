### vpc_id         = "vpc-0e939a73aed858b36"     ## Security_VPC
### subnet_id_1a   = "subnet-0af9523ff318d0607"  ## Security_AZ-A
### subnet_id_1b   = "subnet-04bd184288a226fb7"  ## Secuirty_AZ-B
### sg_id          = "sg-04b4c593629f2e84c"      ## Main_Prod_App_VPC_All_Open_SG
### windows_ami_id = "ami-09d496c26aa745869"     ## Windows 2016

region_name = "us-east-1"

vpc_id    = "vpc-0e939a73aed858b36"
subnet_id = [ "subnet-0af9523ff318d0607", "subnet-04bd184288a226fb7" ] 

key_name          = "DouProxy-Windows-Key"
instance_type     = "t2.large"
join_to_ad        = true # true or false
min_instance_size = 1
desired_capacity  = 1
max_instance_size = 2
user_data_file    = "windows_ec2.tpl"

default_tags = {
  project_name     = "Symphony"
  client_name      = "Shared"
  application_name = "DouProxy"
  environment_name = "Production"
  security_zone    = "DMZ"
  os_name          = "Windows 2019"
  os_type          = "Windows"
}

