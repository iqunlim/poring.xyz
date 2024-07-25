# Policy Document for the filebucket bucket policy
data "aws_iam_policy_document" "filebucket-bucket-policy" {
    statement {
        principals {
            type = "AWS"
            identifiers = [aws_iam_role.FileserverLambdaRole.arn]
        }
        actions = [
            "s3:GetObject",
            "s3:PutObject"
        ]
        resources = [
            aws_s3_bucket.filebucket.arn,
            "${aws_s3_bucket.filebucket.arn}/*"
        ]
    }
    statement {
        principals {
            type = "AWS"
            identifiers = ["*"]
        }
        actions = [
            "s3:GetObject"
        ]
        resources = [
            "${aws_s3_bucket.filebucket.arn}/*"
        ]
    }
}

resource "aws_s3_bucket" "filebucket" {
    bucket = "files.${var.root_domain}"
    
    tags = {
        Name      = "files.${var.root_domain}"
        Terraform = "True"
    }
    force_destroy = true
    # prevent_destroy pretents this bucket from ever being deleted via terraform.
    # THIS WILL cause an error on terraform destroy if set to true, but if were in production this should be enabled
    lifecycle {
        prevent_destroy = false
    }
}

# Get rid of those nasty public access blocks
# TODO: Verify that this is least privilege 
resource "aws_s3_bucket_public_access_block" "filebucket-publicaccess" {
  bucket = aws_s3_bucket.filebucket.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

# Set the bucket policy 

resource "aws_s3_bucket_policy" "fileservice_policy" {
    bucket = aws_s3_bucket.filebucket.id
    policy = data.aws_iam_policy_document.filebucket-bucket-policy.json
}

# Set the CORS policy
resource "aws_s3_bucket_cors_configuration" "filesrever-cors" {
    bucket = aws_s3_bucket.filebucket.id 
    cors_rule {
        allowed_headers = ["*"]
        allowed_methods = ["PUT", "POST"]
        allowed_origins = ["files.${var.root_domain}"]
        expose_headers  = [
            "x-amz-server-side-encryption",
            "x-amz-request-id",
            "x-amz-id-2"
        ]
        max_age_seconds = 3600
    }
    cors_rule {
        allowed_methods = ["GET"]
        allowed_origins = ["*"]
    }
}

# Finally, set this site as a static website
# This will allow it to act as a fileserver
resource "aws_s3_bucket_website_configuration" "static-s3-fileserver" {
  bucket = aws_s3_bucket.filebucket.id

  index_document {
    suffix = "index.html"
  }
}