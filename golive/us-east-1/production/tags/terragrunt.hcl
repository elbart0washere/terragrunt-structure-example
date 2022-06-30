include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:elbart0washere/terra-aws-tags.git//app?ref=v0.0.1"

  extra_arguments "custom_vars" {
    commands = get_terraform_commands_that_need_vars()

    arguments = [
      "-var-file=${get_terragrunt_dir()}/../ou.tfvars",
      "-var-file=${get_terragrunt_dir()}/../../../globals.tfvars"
    ]
  }
}
########[ EDIT CONTENT SECTION ]##########
locals {
  # Load the data from common.hcl
  common = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  env    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}
### Ejemplo agregando outputs de otros recursos
generate = local.common.generate
generate = local.env.generate


### Ejemplo consumiendo outputs de dependencias

inputs = {
 environment =   join(".", [local.common, local.env])
}
