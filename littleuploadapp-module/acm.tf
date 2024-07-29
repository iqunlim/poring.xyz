# Pregenerated ACM certificate in backend-setup for api.${var.domain}
data "aws_acm_certificate" "api_certificate" {
  domain      = "api.${var.root_domain}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}
# TODO: Pregenerated ACM certificate in backend-setup for ${var.domain}
data "aws_acm_certificate" "lb_certificate" {
  domain      = var.root_domain
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}