#Include root terragrunt.hcl
include {
  path = find_in_parent_folders()
}

#Define module source
terraform {
  source = "git::git@github.com:elbart0washere/terraform-aws-tags.git//app?ref=v0.1.0"
}

#Locals variables
locals {
  vars = read_terragrunt_config(find_in_parent_folders("account_name.hcl"))
}

#Inputs to module
inputs = {
  environment = local.vars.locals.account_name
}
