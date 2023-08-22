# output "bucket_website_domain" {
#   value = aws_s3_bucket_website_configuration.website.website_domain
# }

# output "bucket_hosted_zone_id" {
#   value = aws_s3_bucket.website.hosted_zone_id
# }

# output "bucket_name" {
#   value = aws_s3_bucket.website.bucket
# }

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.website.bucket_regional_domain_name
}