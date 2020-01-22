provider "aws" {
  region = "us-east-1"
}

##############################################################
# Data sources to get VPC, subnets and security group details
##############################################################
#data "aws_vpc" "default" {
#  default = true
#}

data "aws_subnet_ids" "all" {
  #vpc_id = "vpc-069d202f6c6abf29a"
  vpc_id = "vpc-0834143b1d7b2b267"
}

data "aws_security_group" "default" {
  #vpc_id = "vpc-069d202f6c6abf29a"
  vpc_id = "vpc-0834143b1d7b2b267"
  name   = "default"
}

#####
# DB
#####
module "db" {
  source = "../../"

  identifier = "kansasuatdmzdb"

  engine            = "sqlserver-ee"
  engine_version    = "14.00.3223.3.v1"
  instance_class    = "db.m4.xlarge"
  allocated_storage = 20
  storage_encrypted = true

  name     = null #"kansasuatdmzdb"
  username = "kansasuatdmzdbuser"
  password = "KansasUATDMZDbUser"
  port     = "1433"

  vpc_security_group_ids = [data.aws_security_group.default.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # disable backups to create DB faster
  backup_retention_period = 7

  tags = {
    Owner       = "KansasUATUser"
    Environment = "UATDMZ"
  }

  # DB subnet group
  subnet_ids = data.aws_subnet_ids.all.ids

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "kansasuatdmzdb"

  create_db_parameter_group = false
  license_model             = "license-included"

  #timezone = "Central Standard Time"
  #timezone = "Greenwich Mean Time"
   timezone = "Greenwich Standard Time"

  # Database Deletion Protection
  deletion_protection = false

  # DB options
  major_engine_version = "14.00"

  options = []
#    {
#      option_name = "SQLSERVER_BACKUP_RESTORE"
#      option_settings = {
#        name = "IAM_ROLE_ARN"
#        value = "${aws_iam_role.this.arn}"
#      }
#    }
#]
}
