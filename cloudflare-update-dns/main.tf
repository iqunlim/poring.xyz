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
  name    = "api.${var.root_domain}"
  type    = "CNAME"
  value   = var.api_domain_value
  proxied = false
}
resource "cloudflare_record" "webhost" {
  zone_id = data.cloudflare_zone.main.zone_id
  name    = "@"
  type    = "CNAME"
  value   = var.webserver_domain_value
  proxied = true
}

resource "cloudflare_record" "fileserver" {
  zone_id = data.cloudflare_zone.main.zone_id
  name    = "files.${var.root_domain}"
  type    = "CNAME"
  value   = var.fileserver_domain_value
  proxied = true
}

resource "cloudflare_ruleset" "set_no_ssl" {
  zone_id     = data.cloudflare_zone.main.zone_id
  name        = "nossl"
  description = "Set SSL configuration rules for incoming requests"
  kind        = "zone"
  phase       = "http_config_settings"

  rules {
    action = "set_config"
    action_parameters {
      ssl = "off"
    }
    expression  = "(http.host eq \"poring.xyz\")"
    description = "Disable flexible ssl for the root domain as it is signed by aws"
    enabled     = true
  }
}