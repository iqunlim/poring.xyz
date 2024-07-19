# Pregenerated ACM certificate for api.${var.domain}
data "aws_acm_certificate" "api_certificate" {
  domain      = "api.${var.root_domain}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}
# If not pregenerated, comment the above and uncomment this, then do the opposite next deployment