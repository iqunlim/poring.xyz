
# Policy Document so that the lambda or anything else I need to access the bucket can put files
data "aws_iam_policy_document" "S3AppPolicy" {
    statement {
        actions = [
            "s3:GetObject",
            "s3:PutObject"
        ]
        resources = [data.aws_s3_bucket.filebucket.arn]
    }
}

# Policy Document for Lambda Execution. ALL LAMBDAS will need this to function!
# TODO: This is currently not attaching! Something must be wrong.... 
data "aws_iam_policy_document" "BasicLambdaExecutionRole" {
    statement {
        actions = ["logs:CreateLogGroup"]
        resources = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"]
    }
    statement {
        actions = [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ]
        resources = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:/aws/lambda/Get-Signed-S3-${var.production ? "Dev" : "Prod"}:*"]
    }
}

## AssumeRole for the lambda
data "aws_iam_policy_document" "LambdaAllow" {
    statement {
        principals {
            type = "Service"
            identifiers = ["lambda.amazonaws.com"]
        }
        actions = ["sts:AssumeRole"]
    }
}

# Turn the documents in to attachable policies with ARNs
resource "aws_iam_policy" "S3AppPolicy" {
    name = "S3AppPolicy"
    path = "/fileserver/"
    description = "Requirements for a fileserver to function"
    policy = data.aws_iam_policy_document.S3AppPolicy.json

    tags = {
        Terraform = "True"
    }
}

resource "aws_iam_policy" "BasicLambdaExecutionRole" {
    name = "BasicLambdaExecutionRole"
    path = "/fileserver/"
    description = "All Lambdas require a version of this"
    policy = data.aws_iam_policy_document.BasicLambdaExecutionRole.json
}

# Create the Lambda role

resource "aws_iam_role" "FileserverLambdaRole" {
    name = "FileserverLambdaRole"
    assume_role_policy = data.aws_iam_policy_document.LambdaAllow.json
    managed_policy_arns = [aws_iam_policy.S3AppPolicy.arn, aws_iam_policy.BasicLambdaExecutionRole.arn]

    tags = {
        Terraform = "True"
    }
}

