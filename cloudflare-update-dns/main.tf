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
  name = var.root_domain
}

resource "cloudflare_record" "api" {
  zone_id = data.cloudflare_zone.main.zone_id
  name    = "api.${root_domain}"
  type    = "CNAME"
  value   = var.api_domain_value
  proxied = true
}
resource "cloudflare_record" "webhost" {
  zone_id = data.cloudflare_zone.main.zone_id
  name = var.root_domain
  type = "CNAME"
  value = var.webserver_domain_value
  proxied = true
}