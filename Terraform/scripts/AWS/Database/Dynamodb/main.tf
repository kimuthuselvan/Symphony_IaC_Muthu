provider "aws" {
  region = "us-east-1"
}

resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "Symphony-Kansas-UAT"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "KansasUserId"
  range_key      = "KansasTableTitle"

  attribute {
    name = "KansasUserId"
    type = "S"
  }

  attribute {
    name = "KansasTableTitle"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  global_secondary_index {
    name               = "KansasTableTitleIndex"
    hash_key           = "KansasTableTitle"
    write_capacity     = 5
    read_capacity      = 5
    projection_type    = "INCLUDE"
    non_key_attributes = ["KansasUserId"]
  }

  tags = {
    Name        = "Symphony-Kansas-UAT"
    Project     = "Symphony"
    Client      = "Kansas"
    Environment = "UAT-DMZ"
  }
}

