variable "root_domain" {
    description = "The root domain for the whole app"
    type = string
}

variable "cloudflare_api_key" {
    description = "Cloudflare API key for DNS entry puts"
    type = string
}