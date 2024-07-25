# Global Variables

variable "region" {
  description = "Region to deploy this module to"
  type        = string
  default     = "us-east-2"
}

# VPC Variable

variable "api_interface_endpoint" {
    description = "Create a VPC interface endpoint for the API Backend"
    type        = bool
    default     = false
}

variable "root_domain" {
  description = "The root domain, var.domain is the fileserver domain"
  type = string
}

variable "production" {
  description = "Are we in prod?"
  type = bool
  default = false
}

variable "prevent_destroy_of_s3_filebucket" {
  description = "This should be enabled in production. Allows the destruction of the bucket on terraform destroy."
  type = bool 
  default = true
}