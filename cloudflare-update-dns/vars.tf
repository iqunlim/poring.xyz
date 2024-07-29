variable "cloudflare_api_token" {
  description = "Cloudflare API Token"
  type        = string
}

variable "root_domain" {
  description = "the overarching domain that will have records put to"
  type        = string
}

variable "webserver_domain_value" {
  description = "The URL to the Webhost"
  type        = string
}

variable "fileserver_domain_value" {
  description = "The URL to the Fileserver. file.<domain> for now."
  type        = string
}

variable "api_domain_value" {
  description = "The URL to the API Gateway custom domain regional endpoint"
  type        = string
}