output "api_domain_url" {
    description = "The base URL to send all API requests to"
    value = aws_api_gateway_domain_name.api_gateway_domain.regional_domain_name
}

output "s3_static_domain_url" {
    description = "This URL will attach to var.domain on cloudflare"
    # Do not use website_endpoint, it will add the https:// which makes the dns records fail!
    value = trim(aws_s3_bucket_website_configuration.static-s3-fileserver.website_domain, "http://")
}
# Subject to change as compute shifts to ECS or whatever else
output "webserver_domain_ip" {
    description = "The URL directly to the webserver instance"
    value = aws_instance.webserver.public_ip
}