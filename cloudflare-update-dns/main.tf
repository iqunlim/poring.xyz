terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

data "cloudflare_zone" "main" {
  name = var.domain
}

/*resource "cloudflare_record" "api" {
  zone_id = data.cloudflare_zone.main.zone_id
  name    = var.api_subdomain
  type    = "CNAME"
  value   = var.api_domain_value
  proxied = true
}*/
resource "cloudflare_record" "webhost" {
  zone_id = data.cloudflare_zone.main.zone_id
  name = var.webserver_subdomain
  type = "CNAME"
  value = var.webserver_domain_value
  proxied = true
}