locals {
  name = lower("${var.default_tags["project_name"]}-${var.default_tags["client_name"]}-${var.default_tags["service_role"]}")
}

data "aws_iam_policy_document" "site_policy" {
  statement {
    sid = "PublicReadGetObject"
    principals {
        type        = "AWS"
        identifiers = ["*"]
    }
    actions = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${local.name}/*"]
  }
}

resource "aws_s3_bucket" "contentbucket" {
  bucket = local.name
  region = var.region_name
  acl    = "public-read"
  force_destroy = "true"
  policy        = data.aws_iam_policy_document.site_policy.json
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["HEAD", "GET", "PUT", "POST", "DELETE"]
    allowed_origins = ["*"]
    expose_headers = ["ETag"]
    max_age_seconds = "0"
  }

  website {
    index_document = "maintenance.html"
  }

  tags = var.default_tags
}

resource "aws_s3_bucket_object" "uploadfiles" {
  for_each = fileset("${path.module}/files", "**/*")

  bucket = aws_s3_bucket.contentbucket.bucket
  key    = each.value
  source = "${path.module}/files/${each.value}"
  content_type = "text/html"
}

/**
output "bucketname" {
  value = aws_s3_bucket.contentbucket.bucket
}

output "bucketdomain" {
  value = "${aws_s3_bucket.contentbucket.bucket}.s3-website-${var.region_name}.amazonaws.com"
}
**/

