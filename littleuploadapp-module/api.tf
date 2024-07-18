# The main resource
resource "aws_api_gateway_rest_api" "littleupload_api" {
    name = "littleupload_api"

    endpoint_configuration {
        types = ["REGIONAL"]
    }
}

# This creates /sign-s3 as a url on the API
resource "aws_api_gateway_resource" "Sign-S3" {
    rest_api_id = aws_api_gateway_rest_api.littleupload_api.id
    parent_id = aws_api_gateway_rest_api.littleupload_api.root_resource_id
    path_part = "sign-s3"
}

# This gives the /sign-s3 a GET method
resource "aws_api_gateway_method" "Sign-S3-GET" {
    rest_api_id = aws_api_gateway_rest_api.littleupload_api.id
    resource_id = aws_api_gateway_resource.Sign-S3.id
    http_method = "GET"
    authorization = "NONE" # TODO: Add authorization to the API
}

# This is the integration request (what you actually want to do with the API)
# This is set up to point to the pre-created lambda function GetSignedS3
# and will get the response back as json
resource "aws_api_gateway_integration" "Sign-S3-Lambda" {
    rest_api_id = aws_api_gateway_rest_api.littleupload_api.id
    resource_id = aws_api_gateway_resource.Sign-S3.id
    http_method = aws_api_gateway_method.Sign-S3-GET.http_method
    integration_http_method = "POST"
    type = "AWS" # TODO: Look in to AWS_PROXY integration request setting
    uri = aws_lambda_function.GetSignedS3.invoke_arn
}

resource "aws_api_gateway_method_response" "get_response_200" {
    rest_api_id = aws_api_gateway_rest_api.littleupload_api.id
    resource_id = aws_api_gateway_resource.Sign-S3.id
    http_method = aws_api_gateway_method.Sign-S3-GET.http_method
    status_code = "200"
}

resource "aws_api_gateway_method_response" "options_response_200" {
    rest_api_id = aws_api_gateway_rest_api.littleupload_api.id
    resource_id = aws_api_gateway_resource.Sign-S3.id
    http_method = aws_api_gateway_method.Sign-S3-OPTIONS.http_method
    status_code = "200"
    response_parameters = {
        
    }
}


# CORS from here below
# This response is for the CORS policy
# TODO: Make this only origin = var.domain after testing
resource "aws_api_gateway_integration_response" "Sign-S3-Lambda" {
    rest_api_id = aws_api_gateway_rest_api.littleupload_api.id
    resource_id = aws_api_gateway_resource.Sign-S3.id
    http_method = aws_api_gateway_method.Sign-S3-GET.http_method

    response_parameters = {
        "method.response.header.Access-Control-Allow-Origin":"*"
    }
    status_code = aws_api_gateway_method_response.get_response_200.status_code
}
# This returns the CORS headers
resource "aws_api_gateway_method" "Sign-S3-OPTIONS" {
    rest_api_id = aws_api_gateway_rest_api.littleupload_api.id
    resource_id = aws_api_gateway_resource.Sign-S3.id
    http_method = "OPTIONS"
    authorization = "NONE" # TODO: Add authorization to the API
}

# This is the integration response with it for the CORS headers
resource "aws_api_gateway_integration_response" "Sign-S3-Options" {
    rest_api_id = aws_api_gateway_rest_api.littleupload_api.id
    resource_id = aws_api_gateway_resource.Sign-S3.id
    http_method = aws_api_gateway_method.Sign-S3-OPTIONS.http_method

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers":"Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token"
        "method.response.header.Access-Control-Allow-Methods":"GET,OPTIONS"
        "method.response.header.Access-Control-Allow-Origin":"*"
    }
    status_code = aws_api_gateway_method_response.options_response_200.status_code
}