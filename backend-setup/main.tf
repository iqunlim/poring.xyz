terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Sets up a place for tf state files to end up so that we can collaboratively use this or use it for automation setups for CD
resource "aws_s3_bucket" "terraform_state_files" {
  bucket        = var.tflock-bucket-name
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption_conf" {
  bucket = aws_s3_bucket.terraform_state_files.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# The hash key for locking dynamodb table for remote MUST be name LockID with type S or remote backend will fail
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

# TODO: Set up the ACM certificate that will be used by data in the module
# "api.${var.root_domain}"
resource "aws_acm_certificate" "api_certificate" {
  domain_name = "api.${var.root_domain}"
  validation_method = "DNS"

  tags = {
    Terraform = "True"
  }

  lifecycle {
    prevent_destroy = true
  }

  validation_option {
    domain_name = "api.${var.root_domain}"
    validation_domain = var.root_domain
  }
}

resource "aws_acm_certificate" "lb_certificate" {
  domain_name = "${var.root_domain}"
  validation_method = "DNS"

  tags = {
    Terraform = "True"
  }

  lifecycle {
    prevent_destroy = true
  }

  validation_option {
    domain_name = "${var.root_domain}"
    validation_domain = var.root_domain
  }
}


# For now, I am going to do the validation manually
# In the future, this will be a route53 record that will utilize aws_acm_validation
# OR it will be wired from here in to a cloudflare record automatically
output "validation_json" {
  value = aws_acm_certificate.api_certificate.domain_validation_options
}

output "validation_json_root_domain" {
  value = aws_acm_certificate.lb_certificate.domain_validation_options
}