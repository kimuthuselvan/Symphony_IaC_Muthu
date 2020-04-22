provider "aws" {
  region = var.region_name
}

resource "aws_security_group" "symkanesprd" {
  name = "Symphony_Kansas_ElasticSearch_Production_SG"
  vpc_id = var.vpc_id

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

resource "aws_elasticsearch_domain" "symkanesprd" {
  domain_name           = var.domain_name
  elasticsearch_version = "6.8"

  cluster_config {
    instance_type = var.instance_type
    instance_count = 2
    dedicated_master_enabled = true
    dedicated_master_count = 3
    dedicated_master_type = var.instance_type
    zone_awareness_enabled = true
    zone_awareness_config {
      availability_zone_count = 2
    }
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp2"
    volume_size = 20
    #iops =
  }

  vpc_options {
    subnet_ids = var.subnet_ids
    security_group_ids = ["${aws_security_group.symkanesprd.id}"]
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  domain_endpoint_options {
    enforce_https = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  encrypt_at_rest {
    enabled = true
  }

  node_to_node_encryption {
    enabled = true
  }

  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "arn:aws:es:${var.region_name}:945116902499:domain/${var.domain_name}/*"
        }
    ]
}
CONFIG

  snapshot_options {
    automated_snapshot_start_hour = 0
  }

  tags = {
    Domain = var.domain_name
    Project = var.project_name
    Client = var.client_name
    Environment = var.environment_name
    Zone = var.zone_name
  }

 # depends_on = [
 #   "aws_iam_service_linked_role.es",
 # ]
}
