#Include root terragrunt.hcl
include {
  path = find_in_parent_folders()
}

#Define module source
terraform {
  source = "git::git@github.com:elbart0washere/terraform-aws-vpc.git//app?ref=v0.1.0"
}

#Dependencies block

dependency "tags" {
  config_path = "../tags"
}

dependency "tags" {
  config_path = "${get_terragrunt_dir()}/../tags"
}

#$$ Locals vars
locals {
  vars = read_terragrunt_config(find_in_parent_folders("account_name.hcl"))
  inputs = yamldecode(file("${get_terragrunt_dir()}/inputs.yaml"))
}

#$$ inputs to module
inputs = {
  vpc_name                   = local.vars.locals.name
  vpc_cidr                   = local.inputs.vpc.cidr
  azs                        = local.inputs.vpc.subnets.azs
  public_subnets             = local.inputs.vpc.subnets.public
  private_subnets            = local.inputs.vpc.subnets.private
  enable_dns_hostnames       = local.inputs.vpc.enable_dns_hostnames
  enable_nat_gateway         = local.inputs.vpc.enable_nat_gateway
  enable_s3_endpoint         = local.inputs.vpc.enable_s3_endpoint
  enable_dynamodb_endpoint   = local.inputs.vpc.enable_dynamodb_endpoint
  enable_dhcp_options        = local.inputs.vpc.enable_dhcp_options

  tags = dependency.tags.outputs.all["devops-team"]
}
