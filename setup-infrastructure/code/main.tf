resource "aws_iam_policy" "s3_website_terraform" {
  name   = "S3WebsiteTerraformAccess"
  policy = file("./policies/s3_website_terraform_access.json")
}

module "github-oidc" {
  source  = "terraform-module/github-oidc-provider/aws"
  version = "~> 1"

  create_oidc_provider = true
  create_oidc_role     = true

  repositories              = var.repositories
  oidc_role_attach_policies = [aws_iam_policy.s3_website_terraform.arn]
}
