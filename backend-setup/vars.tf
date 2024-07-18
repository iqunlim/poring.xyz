variable "region" {
  description = "Region to deploy this module to"
  type        = string
  default     = "us-east-2" # This should be us-east-1 when deployed to main
}

variable "tflock-bucket-name" {
  description = "This will be the name of the bucket where the lock files for collaboration exist"
  type = string 
}