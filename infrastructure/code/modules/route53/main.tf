# Data block to fetch root domain
data "aws_route53_zone" "root_domain" {
  name = var.root_domain
}

# Create hosted zone for the application to use
resource "aws_route53_zone" "app_hosted_zone" {
  name = var.app_hosted_zone_domain
}

# Add NS record for application hosted zone in root domain hosted zone
module "route53_root_dns_records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = data.aws_route53_zone.root_domain.name

  records = [
    {
      name    = "${var.app_hosted_zone_name}"
      type    = "NS"
      ttl     = 60
      records = aws_route53_zone.app_hosted_zone.name_servers
    }
  ]
}

# Add DNS records in app hosted zone. Create A record for app_subdomain to point to cloudfront
module "route53_app_dns_records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = aws_route53_zone.app_hosted_zone.name

  records = [
    {
      name = "${var.app_subdomain}"
      type = "A"
      alias = {
        name                   = var.cloudfront_domain_name
        zone_id                = var.cloudfront_hosted_zone_id
        evaluate_target_health = false
      }
    }
  ]

  depends_on = [
    aws_route53_zone.app_hosted_zone
  ]
}
