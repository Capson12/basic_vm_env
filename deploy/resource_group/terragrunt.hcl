include "root" {
  path = find_in_parent_folders()
}

locals {
  parent = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl")).locals
}

terraform {
  source = "../../core/resource_group"
}

inputs = {
  name     = "${local.parent.name}-rg"
  location = local.parent.location
  tags = {
    environment = local.parent.environment
  }
}
