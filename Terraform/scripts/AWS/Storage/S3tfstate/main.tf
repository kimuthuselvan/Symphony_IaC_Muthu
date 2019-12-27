provider "aws" {
  region = "${var.region_name}"
  version = "~> 2.7"
}

resource "aws_s3_bucket" "main" {
  region = "${var.region_name}"
  bucket = "${var.s3bucket_name}"
  acl = "private"
  tags = {
    Name = "${var.s3bucket_name}"
    Project = "${var.project_name}"
    Organization = "${var.organization_name}"
    Client = "${var.client_name}"
  }

  lifecycle {
    prevent_destroy = "false"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "state"
    prefix  = "state/"
    enabled = true

    noncurrent_version_expiration {
      days = 90
    }
  }
}

