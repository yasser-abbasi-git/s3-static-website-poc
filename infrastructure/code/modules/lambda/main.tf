resource "aws_iam_role" "invalidate_cloudfront_cache" {
  name  = "invalidate_cloudfront_cache"
  assume_role_policy = file("${path.module}/policies/invalidate_cache_assume_role_policy.json")
}

resource "aws_iam_policy" "invalidate_cloudfront_cache" {
  name        = "invalidate_cloudfront_cache"
  description = "Policy to allow cloudfront cache invalidations"

  policy = file("${path.module}/policies/invalidate_cache_policy.json")
}

resource "aws_iam_role_policy_attachment" "invalidate_cloud_front_attachment" {
  role       = aws_iam_role.invalidate_cloudfront_cache.name
  policy_arn = aws_iam_policy.invalidate_cloudfront_cache.arn
}

data "archive_file" "invalidate_cloudfront_cache_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/invalidate_cache.py"
  output_path = "${path.module}/invalidate_cache.zip"
}

resource "aws_lambda_function" "invalidate_cloudfront_lambda" {
  filename         = data.archive_file.invalidate_cloudfront_cache_lambda_zip.output_path
  function_name    = "invalidate_cloudfront_on_s3_change"
  role             = aws_iam_role.invalidate_cloudfront_cache.arn
  handler          = "invalidate_cache.s3_change_handler"
  source_code_hash = data.archive_file.invalidate_cloudfront_cache_lambda_zip.output_base64sha256
  runtime          = "python3.11"

  environment {
    variables = {
      CLOUDFRONT_DISTRIBUTION_ID = var.cloudfront_distribution_id
    }
  }
}

resource "aws_lambda_permission" "allow_s3_event_notifications" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.invalidate_cloudfront_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.bucket_arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.invalidate_cloudfront_lambda.arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
}