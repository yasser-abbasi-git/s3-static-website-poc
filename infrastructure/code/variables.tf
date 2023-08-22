variable "region" {
  description = "The default AWS region to use for provisioning infrastructure"
  type        = string
  default     = "eu-west-2"

  validation {
    condition     = can(regex("[a-z][a-z]-[a-z]+-[1-9]", var.region))
    error_message = "Must be valid AWS region name"
  }
}

variable "project_name" {
  description = "The name of the project used for tagging resources"
  type        = string
  default     = "s3-static-website-poc"
}

variable "bucket_name" {
  default = "web.static.yasserabbasi.com"
}

variable "root_domain" {
  default = "yasserabbasi.com"
}

variable "app_subdomain" {
  description = "Sub-domain for the application"
  type        = string
  default     = "web"
}

variable "app_hosted_zone_name" {
  description = "Name of the hosted zone for the application dns records"
  type        = string
  default     = "static"
}
