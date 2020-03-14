resource "aws_db_subnet_group" "kansas_prd_sqlserver" {
  name       = "symphony-sqlserver-prd-subnet-group"
  description = "Database subnet group for"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "Symphony-PRD-DB-Subnet-Group"
  }
}

resource "aws_security_group" "kansas_prd_sqlserver" {
  name = "symphony-sqlserver-prd-security-group"
  vpc_id = var.vpc_id

  ingress {
    from_port = 1433
    to_port = 1433
    protocol = "tcp"
    cidr_blocks = ["${var.cidr_ip_1}", "${var.cidr_ip_2}", "${var.cidr_ip_3}", "${var.cidr_ip_4}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${var.cidr_ip_1}", "${var.cidr_ip_2}", "${var.cidr_ip_3}", "${var.cidr_ip_4}"]
  }

  tags = {
    Name = "Test-Symphony-SQLServer-PRD-SG"
    Project = "Symphony"
    Client = "Kansas"
    Environment = "PRD"
    Zone = "Trusted"
  }
}

resource "aws_db_instance" "kansas_prd_sqlserver" {
  depends_on                = [aws_db_subnet_group.kansas_prd_sqlserver]
  identifier                = "testsymkanprddb"
  #name                      = "test-symphony-sqlserver"
  engine                    = "sqlserver-ee"
  engine_version            = "14.00.3223.3.v1"
  #major_engine_version      = "14.00"
  license_model             = "license-included"
  instance_class            = "db.m4.xlarge"
  port                      = "1433"
  storage_type              = "gp2"
  storage_encrypted         = true
  allocated_storage         = 20
  max_allocated_storage     = 1000
  parameter_group_name      = "default.sqlserver-ee-14.0"
  db_subnet_group_name      = "${aws_db_subnet_group.kansas_prd_sqlserver.id}"
  vpc_security_group_ids    = ["${aws_security_group.kansas_prd_sqlserver.id}"]
  multi_az                  = true
  timezone                  = "Greenwich Standard Time"
  username                  = "testsqluser"
  password                  = "_t3stsqlus3r_"
  maintenance_window        = "Mon:00:00-Mon:03:00"
  backup_window             = "03:00-06:00"
  backup_retention_period   = 3
  final_snapshot_identifier = "test-symphony-sqlserver-prd-final-snapshot"
  skip_final_snapshot       = true

  timeouts {
    create = lookup(var.timeouts, "create", null)
    delete = lookup(var.timeouts, "delete", null)
    update = lookup(var.timeouts, "update", null)
  }

  tags = {
    Name = "Test-Symphony-SQLServer-PRD"
    Project = "Symphony"
    Client = "Kansas"
    Environment = "PRD"
    Zone = "Trusted"
  }
}

resource "aws_db_option_group" "kansas_prd_sqlserver" {
  name = "test-symphony-db-prd-option-group"
  option_group_description = "test-symphony-db-prd-option-group"
  engine_name = "sqlserver-ee"
  major_engine_version = "14.00"

  option {
    option_name = "SQLSERVER_BACKUP_RESTORE"

    option_settings {
      name  = "IAM_ROLE_ARN"
      value = "arn:aws:iam::945116902499:role/service-role/rds-backup-role"
    }
  }
  
  tags = {
    Name = "Test-Symphony-DB-Prd-Option-Group"
    Project = "Symphony"
    Client = "Kansas"
    Environment = "PRD"
    Zone = "Trusted"
  }
}

resource "aws_db_parameter_group" "kansas_prd_sqlserver" {
  name = "test-symphony-db-prd-parameter-group"
  family = "sqlserver-ee-14.0"
/**
  parameter {
    name = "character_set_server"
    value = "utf8"
  }

  parameter {
    name = "character_set_client"
    value = "utf8"
  }
**/
  tags = {
    Name = "Test-Symphony-DB-PRD-Parameter-Group"
    Project = "Symphony"
    Client = "Kansas"
    Environment = "PRD"
    Zone = "Trusted"
  }
}

