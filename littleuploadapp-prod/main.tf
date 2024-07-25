terraform { 
  # YOU MUST RUN backend-setup IN ORDER TO UTILIZE THIS, OTHERWISE IT WILL FAIL
  # With an S3 bucket and a dynamodb table created, you can utilize this feature
  # as the terraform lock for collaborative and CI/CD utilization. 
  # This should also be run within the module backend-setup so that it has different tfstate files!
  backend "s3" {
    bucket         = "terraform-state-files-172297794992"
    key            = "littleuploadapp-prod/terraform.tfstate" # Don't forget to change this!
    region         = "us-east-2"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true 
  }
}

# The main module. Will deploy the entire app for one region.
module "littleuploadapp-tf-prod" {
    source = "../littleuploadapp-module"

    region = "us-east-2"
    root_domain = var.root_domain
    prevent_destroy_of_s3_filebucket = true # currently does nothing
    production = true
}

module "cloudflare_setup" {
  source = "../cloudflare-update-dns"

  cloudflare_api_token = var.cloudflare_api_key
  root_domain = var.root_domain
  api_domain_value = module.littleuploadapp-tf-prod.api_domain_url # api.<root_domain>
  webserver_domain_value = module.littleuploadapp-tf-prod.webserver_domain_url # <root_domain>
  fileserver_domain_value = module.littleuploadapp-tf-prod.s3_static_domain_url # files.<root_domain>
}