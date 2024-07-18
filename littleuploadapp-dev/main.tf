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
    region = var.region # Change this to something other than the app region if you wish.
    domain = var.domain # For other regions or for a test-prod setup, this should be different as to not cause overlap
    prevent_destroy_of_s3_filebucket = false
}