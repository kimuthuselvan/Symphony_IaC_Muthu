provider "aws" {
  region = var.region_name
}

resource "aws_elasticache_subnet_group" "symkanecprd" {
  name       = "${var.cluster_id}-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "symkanecprd" {
  name_prefix = "Symphony_Kansas_ElastiCache_Production_SG"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Symphony_Kansas_ElastiCache_Production_SG"
    Project     = var.project_name
    Client      = var.client_name
    Environment = var.environment_name
    Zone        = var.zone_name
  }
}

resource "aws_elasticache_replication_group" "symkanecprd" {
  automatic_failover_enabled    = true
  subnet_group_name             = aws_elasticache_subnet_group.symkanecprd.name
  security_group_ids            = [aws_security_group.symkanecprd.id]
  availability_zones            = ["${var.region_name}a", "${var.region_name}b"]
  replication_group_id          = "${var.cluster_id}-replication-group"
  replication_group_description = "Replication group for Symphony Kansas"
  engine                        = var.engine_name
  engine_version                = var.engine_version
  node_type                     = var.node_type
  number_cache_clusters         = var.num_cache_nodes
  parameter_group_name          = var.parameter_group_name
  port                          = var.port
  snapshot_retention_limit      = 7
  snapshot_window               = "04:30-05:30"
  maintenance_window            = "tue:09:30-tue:10:30"
  at_rest_encryption_enabled    = true
  transit_encryption_enabled    = true
}

resource "aws_elasticache_cluster" "symkanecprd" {
  count = 1
  cluster_id               = "${var.cluster_id}-${count.index}"
  replication_group_id     = aws_elasticache_replication_group.symkanecprd.id

  tags = {
    Name        = var.cluster_id
    Project     = var.project_name
    Client      = var.client_name
    Environment = var.environment_name
    Zone        = var.zone_name
  }
}
