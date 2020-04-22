## Create S3 bucket to store target IPs
resource "aws_s3_bucket" "static_lb" {
  bucket = "sym-kan-nlb-us-east-1"
  acl    = "private"
  region = "us-east-1"

  versioning {
    enabled = true
  }
}

