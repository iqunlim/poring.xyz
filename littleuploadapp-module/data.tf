# Global Data Modules
# Most data modules will be in their respective sections. These are ONLY for ones that are used in many places

# AWS Account that is executing various functions. This is mostly used in IAM policy documents to generate ARNs
data "aws_caller_identity" "current" {}

# Get the created bucket in backend-setup to use in this module. 
# This bucket should never be deleted! So it is set up before hand
data "aws_s3_bucket" "filebucket" {
    bucket = "${var.domain}"
}