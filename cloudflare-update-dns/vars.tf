variable "cloudflare_api_token" {
    description = "Cloudflare API Token"
    type = string
}

variable "root_domain" {
    description = "the overarching domain that will have records put to"
    type = string
}

# For now, we will not be applying an api subdomain.
# Please see: https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-custom-domains.html
variable "api_domain_value" {
    description = "The URL to the API Gateway. api.<domain>"
    type = string
}

variable "webserver_domain_value" {
    description = "The URL to the Webhost"
    type = string
}

/*variable "webserver_subdomain" {
    description = "The prefix you would like for the webhost if you do not want it to be the root of the domain"
    type = string
    default = "@"
}*/