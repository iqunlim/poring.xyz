terraform { 
  # YOU MUST RUN backend-setup IN ORDER TO UTILIZE THIS, OTHERWISE IT WILL FAIL
  # With an S3 bucket and a dynamodb table created, you can utilize this feature
  # as the terraform lock for collaborative and CI/CD utilization. 
  # This should also be run within the module backend-setup so that it has different tfstate files!
  backend "s3" {
    bucket         = "terraform-state-files-172297794992"
    key            = "littleuploadapp-dev/terraform.tfstate" # Don't forget to change this!
    region         = "us-east-2"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true 
  }
}

# The main module. Will deploy the entire app for one region.
module "littleuploadapp-tf-dev" {
    source = "../littleuploadapp-module"

    #TODO: Add vars here
    region = var.region
    root_domain = var.root_domain 
    fs_domain = var.fs_domain
    prevent_destroy_of_s3_filebucket = false
}

output "api_invoke_url" {
    description = "The base URL to send all API requests to"
    value = module.littleuploadapp-tf-dev.api_invoke_url
}

output "s3_static_domain_url" {
    description = "This URL will attach to var.domain on cloudflare"
    value = module.littleuploadapp-tf-dev.s3_static_domain_url
}