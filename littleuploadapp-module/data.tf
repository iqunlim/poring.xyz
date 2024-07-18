# Global Data Modules
# Most data modules will be in their respective sections. These are ONLY for ones that are used in many places

# AWS Account that is executing various functions. This is mostly used in IAM policy documents to generate ARNs
data "aws_caller_identity" "current" {}