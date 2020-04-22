provider "aws" {
  region = var.region_name
}

resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = var.dynamodb_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = var.hash_key

  attribute {
    name = var.hash_key
    type = "N"
  }

  server_side_encryption {
    enabled = true
  }

  tags = {    
    Name        = var.dynamodb_name
    Project     = var.project_name
    Client      = var.client_name
    Environment = var.environment_name
    Zone = var.zone_name
  }
}

