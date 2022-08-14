
# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract the variables we need for easy access
  aws_region              = local.accounts_vars.region
  bucket_name             = "terraform-state-${locals.environment_vars.env}-${locals.accounts_vars.account_name}"
  aws_account_id          = local.account_vars.aws_account_id
  aws_assume_role_name    = local.account_vars.aws_assume_role_name
  s3_aws_assume_role_name = local.account_vars.s3_aws_assume_role_name
  profile                 = local.accounts_vars.locals.profile
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region  = "${local.aws_region}"
  profile = "${local.profile}"
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
    profile        = local.profile
    bucket         = local.bucket_name 
    region         = local.aws_region
    assume_role {
     role_arn = "arn:aws:iam::${local.aws_account_id}:role/${local.aws_assume_role_name}"
  }

    key            = "us-east-1/${path_relative_to_include()}/terraform.tfstate"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
