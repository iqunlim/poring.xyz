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
  proxied = false
}
resource "cloudflare_record" "webhost" {
  zone_id = data.cloudflare_zone.main.zone_id
  name = var.root_domain
  # using CNAME for the root domain is only possible with CNAME flattening and cloudflare does it for free!
  type = "CNAME"
  value = var.webserver_domain_value
  proxied = true
}

resource "cloudflare_record" "fileserver" {
  zone_id = data.cloudflare_zone.main.zone_id
  name = "files.${root_domain}"
  type = "CNAME"
  value = var.fileserver_domain_value
  proxied = false
}