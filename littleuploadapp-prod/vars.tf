variable "region" {
  description = "Region to deploy this module to"
  type        = string
  default     = "us-east-2"
}

variable "domain" {
  description = "The domain that will act as the fileserver and website all-in-one"
  type = string
}