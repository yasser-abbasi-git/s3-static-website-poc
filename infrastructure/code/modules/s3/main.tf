# Create bucket for the static website
resource "aws_s3_bucket" "website" {
  bucket        = var.bucket_name
  force_destroy = true
  tags = {
    Name = "${var.project_name}-bucket"
  }
}

# Create website configuration for the static website bucket
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }

}

# Create bucket policy for website bucket
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.allow_cloudfront.json
}

# Data block for bucket policy allowing traffic to the bucket from cloudfront
data "aws_iam_policy_document" "allow_cloudfront" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [var.cloudfront_arn]
    }
  }
}