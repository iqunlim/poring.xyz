# Pregenerated ACM certificate in backend-setup for api.${var.domain}
data "aws_acm_certificate" "api_certificate" {
  domain      = "api.${var.root_domain}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}