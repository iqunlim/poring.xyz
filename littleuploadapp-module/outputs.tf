output "api_domain_url" {
    description = "The base URL to send all API requests to"
    value = aws_api_gateway_domain_name.api_gateway_domain.regional_domain_name
}

output "s3_static_domain_url" {
    description = "This URL will attach to var.domain on cloudflare"
    value = aws_s3_bucket_website_configuration.static-s3-fileserver.website_endpoint
}
# Subject to change as compute shifts to ECS or whatever else
output "webserver_domain_url" {
    description = "The URL directly to the webserver instance"
    value = aws_instance.webserver.public_dns
}