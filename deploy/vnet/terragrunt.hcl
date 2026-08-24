include "root" {
  path = find_in_parent_folders()
}

locals {
  parent = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl")).locals
}

dependency "resource_group" {
  config_path = "../resource_group"

  mock_outputs = {
    name = "mock-rg"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

terraform {
  source = "../../core/vnet"
}

inputs = {
  prefix               = local.parent.name
  location             = local.parent.location
  resource_group_name  = dependency.resource_group.outputs.name
  address_space        = ["10.0.0.0/16"]
  subnet_address_prefix = ["10.0.1.0/24"]

  # Restrict this to your own IP range before deploying to production
  ssh_source_address_prefixes = ["*"]
}
