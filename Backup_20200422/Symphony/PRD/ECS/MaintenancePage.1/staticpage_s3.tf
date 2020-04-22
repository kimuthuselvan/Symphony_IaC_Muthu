data "aws_iam_policy_document" "site_policy" {
  statement {
    sid = "PublicReadGetObject"
    principals {
        type        = "AWS"
        identifiers = ["*"]
    }
    actions = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.dns_prefix}.${var.dns_hosted_zone}/*"]
  }
}

resource "aws_s3_bucket" "site_bucket" {
  bucket        = "${var.dns_prefix}.${var.dns_hosted_zone}"
  region        = var.region_name
  acl           = "public-read"
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
    index_document = "index.html"
  }
}

resource "aws_s3_bucket_object" "uploadfile" {
  bucket     = aws_s3_bucket.site_bucket.id
  key        = "index.html"
  source     = "files/index.html"
  etag       = filemd5("files/index.html")
  content_type = "text/html"
}
