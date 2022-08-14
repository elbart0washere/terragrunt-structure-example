include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:elbart0washere/terra-aws-eks.git//cluster?ref=v0.1.0"

  extra_arguments "custom_vars" {
    commands  = get_terraform_commands_that_need_vars()
  }
}

locals {
  # Load the data from common.hcl
  account_vars  = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  another_value = "some_hardcode_value"
}
generate = local.account_vars.generate

dependency "tags" {
  config_path = "${get_terragrunt_dir()}/../../tags/"
}

inputs = {
  variable_1        = local.account_vars.account_name
  needed_var        = local.another_value
  tags              = dependency.tags.outputs.tags
}
