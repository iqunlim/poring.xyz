output "api_invoke_url" {
    description = "The base URL to send all API requests to"
    value = aws_api_gateway_deployment.api-deployment.invoke_url
}

output "s3_static_domain_url" {
    description = "This URL will attach to var.domain on cloudflare"
    value = aws_s3_bucket_website_configuration.static-s3-fileserver.website_endpoint
}