# configure aws provider
provider "aws" {
  region = var.region
}

# configure aws provider for N.Virginia (us-east-1)
provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}