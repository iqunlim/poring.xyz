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
    depends_on = [
        aws_api_gateway_resource.Sign-S3
    ]
    request_parameters = {
        "method.request.querystring.fileName" = true
        "method.request.querystring.fileType" = true
        "method.request.querystring.t" = true
        "method.request.path.proxy" = true
    }
}

# This is the integration request (what you actually want to do with the API)
# This is set up to point to the pre-created lambda function GetSignedS3
# and will get the response back as json
resource "aws_api_gateway_integration" "Sign-S3-Lambda" {
    rest_api_id = aws_api_gateway_rest_api.littleupload_api.id
    resource_id = aws_api_gateway_resource.Sign-S3.id
    http_method = "${aws_api_gateway_method.Sign-S3-GET.http_method}"
    integration_http_method = "POST" # If you do not set this as POST, it will cause an auth error!
    type = "AWS" # TODO: Look in to AWS_PROXY integration request setting
    uri = aws_lambda_function.GetSignedS3.invoke_arn

    depends_on = [
        aws_api_gateway_method.Sign-S3-GET
    ]

    request_templates = {
        "application/json" = <<EOF
{
    "fileName":  "$input.params('fileName')",
    "fileType":  "$input.params('fileType')", 
    "t": "$input.params('t')"   
}
EOF
    }
}

resource "aws_api_gateway_integration_response" "Sign-S3-Lambda" {
    rest_api_id = aws_api_gateway_rest_api.littleupload_api.id
    resource_id = aws_api_gateway_resource.Sign-S3.id
    http_method = aws_api_gateway_method.Sign-S3-GET.http_method

    response_parameters = {
        "method.response.header.Access-Control-Allow-Origin" = "'*'"
    }
    
    status_code = aws_api_gateway_method_response.get_response_200.status_code
    depends_on = [
        aws_api_gateway_method.Sign-S3-GET,
        aws_api_gateway_integration.Sign-S3-Lambda
    ]
}

resource "aws_api_gateway_method_response" "get_response_200" {
    rest_api_id = aws_api_gateway_rest_api.littleupload_api.id
    resource_id = aws_api_gateway_resource.Sign-S3.id
    http_method = aws_api_gateway_method.Sign-S3-GET.http_method
    status_code = "200"
    depends_on = [
        aws_api_gateway_method.Sign-S3-GET
    ]
}

# THE OPTIONS RESPONSE
resource "aws_api_gateway_method" "Sign-S3-OPTIONS" {
    rest_api_id = aws_api_gateway_rest_api.littleupload_api.id
    resource_id = aws_api_gateway_resource.Sign-S3.id
    http_method = "OPTIONS"
    authorization = "NONE" # TODO: Add authorization to the API
}

resource "aws_api_gateway_integration" "Sign-S3-Options" {
    rest_api_id = aws_api_gateway_rest_api.littleupload_api.id
    resource_id = aws_api_gateway_resource.Sign-S3.id
    http_method = aws_api_gateway_method.Sign-S3-OPTIONS.http_method
    integration_http_method = "OPTIONS"
    type = "MOCK"
}

# This is the integration response with it for the CORS headers
resource "aws_api_gateway_integration_response" "Sign-S3-Options" {
    rest_api_id = aws_api_gateway_rest_api.littleupload_api.id
    resource_id = aws_api_gateway_resource.Sign-S3.id
    http_method = aws_api_gateway_method.Sign-S3-OPTIONS.http_method

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
        "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
        "method.response.header.Access-Control-Allow-Origin" = "'*'"
    }
    status_code = aws_api_gateway_method_response.options_response_200.status_code

    depends_on = [
        aws_api_gateway_integration.Sign-S3-Options, 
        aws_api_gateway_method_response.options_response_200
    ]
}

resource "aws_api_gateway_method_response" "options_response_200" {
    rest_api_id = aws_api_gateway_rest_api.littleupload_api.id
    resource_id = aws_api_gateway_resource.Sign-S3.id
    http_method = aws_api_gateway_method.Sign-S3-OPTIONS.http_method
    status_code = "200"
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true
        "method.response.header.Access-Control-Allow-Methods" = true
        "method.response.header.Access-Control-Allow-Origin" = true
    }
    response_models = {
        "application/json" = "Empty"
    }
}