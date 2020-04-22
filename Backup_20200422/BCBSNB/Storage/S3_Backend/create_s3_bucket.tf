provider "aws" {
  region = var.region_name
}
data "aws_iam_policy_document" "site_policy" {
  statement {
    principals {
        type        = "AWS"
        identifiers = ["*"]
    }
    sid = "PublicReadGetObject"
    actions = ["s3:GetObject", "s3:GetObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]
  }
}

resource "aws_s3_bucket" "contentbucket" {
  bucket = var.bucket_name
  region = var.region_name
  force_destroy = "true"
  policy = data.aws_iam_policy_document.site_policy.json

}

output "bucketname" {
  value = aws_s3_bucket.contentbucket.bucket
}
