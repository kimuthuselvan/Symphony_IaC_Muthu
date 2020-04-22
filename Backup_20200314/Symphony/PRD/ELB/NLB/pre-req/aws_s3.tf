## Create S3 bucket to store target IPs
resource "aws_s3_bucket" "static_lb" {
  bucket = "kan-sym-nlb"
  acl    = "private"
  region = "us-east-1"

  versioning {
    enabled = true
  }
}

