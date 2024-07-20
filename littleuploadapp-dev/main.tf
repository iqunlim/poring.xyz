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
    region = "us-east-2"
    root_domain = "iqun.xyz"
    fs_domain = "test.iqun.xyz"
    prevent_destroy_of_s3_filebucket = false
}

module "cloudflare_setup" {

  source = "../cloudflare-update-dns"
  cloudflare_api_token = "" #TODO: make this a variable and put it in tfvars 
  root_domain = "iqun.xyz" # This will be extrapolated in to api.<root_domain>
  api_domain_value = module.littleuploadapp-tf-dev.api_domain_url
  webserver_domain_value = module.littleuploadapp-tf-dev.webserver_domain_url
  fileserver_domain_value = module.littleuploadapp-tf-dev.s3_static_domain_url
}