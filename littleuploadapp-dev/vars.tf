variable "region" {
  description = "Region to deploy this module to"
  type        = string
  default     = "us-east-2"
}

variable "root_domain" {
  description = "The domain that will act as the website and root domain"
  type = string
}

variable "fs_domain" {
  description = "The file server domain name or subdomain (include the whole thing)"
  type = string
}