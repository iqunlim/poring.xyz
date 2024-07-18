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

variable "domain" {
  description = "The domain that will act as the fileserver and website all-in-one"
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