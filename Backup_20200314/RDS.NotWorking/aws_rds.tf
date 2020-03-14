provider "aws" {
  region = "us-east-1"
}

resource "aws_db_instance" "eft_rds" {
  vpc_id = "vpc-0b2eba5d72c599770"
  vpc_security_group_ids = ["sg-04b4c593629f2e84c"]
  allocated_storage    = 20
  max_allocated_storage = 100
  storage_type         = "gp2"
  engine               = "sqlserver-se"
  engine_version       = "14.00"
  instance_class       = "db.t2.micro"
  name                 = "eft_rds"
  username             = "eftuser1"
  password             = "3ftU$3r1"
  parameter_group_name = "default.sqlserver-se-14.0"
  timezone             = "Greenwich Standard Time"
  storage_encrypted    = true
  
  tags = {
    Name = "Symphony_EFT_Production_SqlServer"
    Project = "Symphony"
    Client = "Shared"
    Environment = "Production"
    Zone = "Trusted"
  }
}

resource "aws_db_option_group" "eft_rds" {
  name                     = "option-group-eft-rds"
  option_group_description = "EFT RDS Option Group"
  engine_name              = "sqlserver-se"
  major_engine_version     = "14.00"

  option {
    option_name = "Greenwich Standard Time"

    #option_settings {
    #  name  = "TIME_ZONE"
    #  value = "UTC"
    #}
  }

  option {
    option_name = "SQLSERVER_BACKUP_RESTORE"

    option_settings {
      name  = "IAM_ROLE_ARN"
      value = "arn:aws:iam::945116902499:role/service-role/rds-backup-role"
    }
  }

  #option {
  #  option_name = "TDE"
  #}
  tags = {
    Name = "Symphony_EFT_Production_SqlServer"
    Project = "Symphony"
    Client = "Shared"
    Environment = "Production"
    Zone = "Trusted"
  }

  #lifecycle {
  #  create_before_destroy = true
  #}
}

resource "aws_db_parameter_group" "eft_rds" {
  name   = "sqlserver"
  family = "sqlserver-se"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

resource "aws_db_subnet_group" "this" {
  description = "Database subnet group for eft_rds"
  #name_prefix = "eft-rds-"
  #vpc_id = "vpc-0b2eba5d72c599770"
  subnet_ids  = [
    "subnet-0c2bbd3fc6aa29e0d",
    "subnet-0b89a4615bf0fc2b7"
  ]

  tags = {
    Name = "Symphony_EFT_Production_SqlServer"
    Project = "Symphony"
    Client = "Shared"
    Environment = "Production"
    Zone = "Trusted"
  }
}

