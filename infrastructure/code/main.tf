locals {
  app_hosted_zone_domain = "${var.app_hosted_zone_name}.${var.root_domain}"
  static_app_domain      = "${var.app_subdomain}.${local.app_hosted_zone_domain}"
}

# create s3 buckets
module "s3" {
  source         = "./modules/s3"
  bucket_name    = var.bucket_name
  cloudfront_arn = module.cloudfront.cloudfront_arn
}

# Create acm certificate
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"
  providers = {
    aws = aws.virginia
  }
  domain_name         = "*.${local.app_hosted_zone_domain}"
  zone_id             = module.route53.app_hosted_zone_zone_id
  wait_for_validation = true

  tags = {
    Name = "${local.static_app_domain}"
  }

  depends_on = [
    module.route53.app_hosted_zone
  ]
}

# create hosted zone and dns records
module "route53" {
  source                    = "./modules/route53"
  root_domain               = var.root_domain
  app_hosted_zone_domain    = local.app_hosted_zone_domain
  app_hosted_zone_name      = var.app_hosted_zone_name
  app_subdomain             = var.app_subdomain
  cloudfront_domain_name    = module.cloudfront.cloudfront_domain_name
  cloudfront_hosted_zone_id = module.cloudfront.cloudfront_hosted_zone_id
}

# Create Cloudfront distribution
module "cloudfront" {
  source                      = "./modules/cloudfront"
  bucket_regional_domain_name = module.s3.bucket_regional_domain_name
  static_app_domain           = local.static_app_domain
  certificate_arn             = module.acm.acm_certificate_arn
}