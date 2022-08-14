
# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load account-level variables
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract the variables we need for easy access
  aws_region              = local.accounts_vars.locals.region
  bucket_name             = "terraform-state-${local.accounts_vars.locals.environment}-${local.accounts_vars.locals.account_name}"
  aws_account_id          = local.account_vars.locals.aws_account_id
  aws_assume_role_name    = "${local.environment_vars.locals.environment}-terraformer-role"
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region     = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::${local.aws_account_id}:role/${local.aws_assume_role_name}"
  }
}
EOF
}


remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = local.bucket_name 
    region         = local.aws_region
    key            = "us-east-1/${path_relative_to_include()}/terraform.tfstate"
    dynamodb_table = "terraform-locks-table"
    encrypt        = true
  }
}
