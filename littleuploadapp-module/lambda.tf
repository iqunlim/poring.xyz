data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda_function.py"
  output_path = "${path.module}/lambda/lambda_function_payload.zip"
}

resource "aws_lambda_function" "GetSignedS3" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "${path.module}/lambda/lambda_function_payload.zip"
  function_name = "Get-Signed-S3-${var.production ? "Prod" : "Dev"}"
  role          = aws_iam_role.FileserverLambdaRole.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.12"
  # Please see ./lambda/lambda.py for what these variables do
  environment {
    variables = {
      S3_BUCKET = var.domain
      MAX_SIZE = 20
    }
  }
}

# API Gateway attachment
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.GetSignedS3.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.littleupload_api.id}/*/${aws_api_gateway_method.Sign-S3-GET.http_method}${aws_api_gateway_resource.Sign-S3.path}"
}