locals {
  name     = "basic-vm-env"
  location = "uksouth"
  environment = "dev"

  container_name           = "terraform-state"
  backend_resource_group   = "smtx-external-resource"
  backend_storage_account  = "smtxexternalstorage"
}

remote_state {
  backend = "azurerm"
  config = {
    resource_group_name  = local.backend_resource_group
    storage_account_name = local.backend_storage_account
    container_name       = local.container_name
    key                  = "terraform.tfstate"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}
provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {}
}

EOF
}
