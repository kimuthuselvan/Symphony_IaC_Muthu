resource "aws_db_subnet_group" "default_rds_mssql" {
  #count = length(var.vpc_subnet_ids)
  name        = "${var.environment}-rds-mssql-subnet-group"
  description = "The ${var.environment} rds-mssql private subnet group."
  #subnet_ids  = "${element(var.vpc_subnet_ids, count.index)}"
  #subnet_ids = ["subnet-0c2bbd3fc6aa29e0d", "subnet-0b89a4615bf0fc2b7"]
  subnet_ids  = ["subnet-0d670818706131191", "subnet-053362645abd72e3e"]

  tags = {
    Name = "${var.environment}-rds-mssql-subnet-group"
    Env  = "${var.environment}"
  }
}

/***
resource "aws_security_group" "rds_mssql_security_group" {
  name        = "${var.environment}-all-rds-mssql-internal"
  description = "${var.environment} allow all vpc traffic to rds mssql."
  vpc_id      = "var.vpc_id"

  ingress {
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr_blocks}"]
  }

  tags = {
    Name = "${var.environment}-all-rds-mssql-internal"
    Env  = "${var.environment}"
  }
}

resource "aws_security_group" "rds_mssql_security_group_vpn" {
  name        = "${var.environment}-all-rds-mssql-vpn"
  description = "Allow all inbound traffic from vpn to rds mssql."
  vpc_id      = "var.vpc_id"

  ingress {
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr_blocks_vpn}"]
  }

  tags = {
    Name = "${var.environment}-all-rds-mssql-vpn"
    Env  = "${var.environment}"
  }
}
***/

resource "aws_db_instance" "default_mssql" {
  depends_on                = [aws_db_subnet_group.default_rds_mssql]
  identifier                = "${var.environment}-mssql"
  allocated_storage         = var.rds_allocated_storage
  license_model             = "license-included"
  storage_type              = "gp2"
  engine                    = "sqlserver-se"
  engine_version            = "12.00.4422.0.v1"
  instance_class            = var.rds_instance_class
  multi_az                  = var.rds_multi_az
  username                  = var.mssql_admin_username
  password                  = var.mssql_admin_password
  #vpc_security_group_ids    = ["${aws_security_group.rds_mssql_security_group.id}", "${aws_security_group.rds_mssql_security_group_vpn.id}"]
  vpc_security_group_ids    = ["sg-0f2cd5800f1ecfcc7"]
  db_subnet_group_name      = aws_db_subnet_group.default_rds_mssql.id
  backup_retention_period   = 3
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = "${var.environment}-mssql-final-snapshot"
}

// Identifier of the mssql DB instance.
output "mssql_id" {
  value = "${aws_db_instance.default_mssql.id}"
}

// Address of the mssql DB instance.
output "mssql_address" {
  value = "${aws_db_instance.default_mssql.address}"
}
