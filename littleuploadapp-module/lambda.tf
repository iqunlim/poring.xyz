data "archive_file" "lambda" {
  type        = "zip"
  source_file = "./lambda/lambda.py"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda_function_payload.zip"
  function_name = "Get-Signed-S3-${var.production ? "Dev" : "Prod"}"
  role          = aws_iam_role.FileserverLambdaRole.arn
  # handler       = "index.test"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "Python 3.12"
  # Please see ./lambda/lambda.py for what these variables do
  environment {
    variables = {
      S3_BUCKET = var.domain
      MAX_SIZE = 20
    }
  }
}