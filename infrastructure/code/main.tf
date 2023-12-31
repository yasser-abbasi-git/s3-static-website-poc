locals {
  app_hosted_zone_domain = "${var.app_hosted_zone_name}.${var.root_domain}"
  static_app_domain      = "${var.app_subdomain}.${local.app_hosted_zone_domain}"
}

# create s3 buckets
module "s3" {
  source         = "./modules/s3"
  project_name   = var.project_name
  bucket_name    = var.bucket_name
  cloudfront_arn = module.cloudfront.cloudfront_distribution_arn
}

# Create acm certificate
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"
  providers = {
    aws = aws.virginia
  }
  domain_name         = "*.${local.app_hosted_zone_domain}"
  zone_id             = module.route53.hosted_zone_zone_id
  wait_for_validation = true

  tags = {
    Name = "${local.static_app_domain}"
  }

  depends_on = [
    module.route53.hosted_zone
  ]
}

# create hosted zone and dns records
module "route53" {
  source                     = "github.com/yasser-abbasi-git/tfmodule-hostedzone-and-dns?ref=v1.2"
  root_domain                = var.root_domain
  hosted_zone_domain         = local.app_hosted_zone_domain
  hosted_zone_name           = var.app_hosted_zone_name
  subdomain                  = var.app_subdomain
  a_record_alias_domain_name = module.cloudfront.cloudfront_distribution_domain_name
  a_record_alias_zone_id     = module.cloudfront.cloudfront_distribution_hosted_zone_id
}

# Create Cloudfront distribution
module "cloudfront" {
  source                      = "./modules/cloudfront"
  project_name                = var.project_name
  bucket_regional_domain_name = module.s3.bucket_regional_domain_name
  static_app_domain           = local.static_app_domain
  certificate_arn             = module.acm.acm_certificate_arn
}

# Create Cloudfront distribution
module "lambda" {
  source                     = "./modules/lambda"
  cloudfront_distribution_id = module.cloudfront.cloudfront_distribution_id
  bucket_id                  = module.s3.bucket_id
  bucket_arn                 = module.s3.bucket_arn
}