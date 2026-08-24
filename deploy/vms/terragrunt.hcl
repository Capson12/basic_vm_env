include "root" {
  path = find_in_parent_folders()
}

locals {
  parent = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl")).locals

  admin_username       = "azureuser"
  ssh_private_key_path = "~/.ssh/id_rsa"

  # Swap this per deployment/environment to run a different bootstrap script
  ansible_playbook = "${get_terragrunt_dir()}/ansible/playbook.yml"
}

dependency "resource_group" {
  config_path = "../resource_group"

  mock_outputs = {
    name = "mock-rg"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "vnet" {
  config_path = "../vnet"

  mock_outputs = {
    subnet_id = "mock-subnet-id"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

terraform {
  source = "../../vms"

  after_hook "bootstrap_ansible" {
    commands     = ["apply"]
    execute      = ["bash", "${get_terragrunt_dir()}/scripts/bootstrap_ansible.sh", local.ansible_playbook, local.ssh_private_key_path, local.admin_username]
    run_on_error = false
  }
}

inputs = {
  resource_group_name = dependency.resource_group.outputs.name
  location             = local.parent.location
  subnet_id            = dependency.vnet.outputs.subnet_id

  vms = {
    vm1 = { name = "${local.parent.name}-vm1", size = "Standard_B2s" }
    vm2 = { name = "${local.parent.name}-vm2", size = "Standard_B2s" }
  }

  admin_username       = local.admin_username
  ssh_public_key       = file("~/.ssh/id_rsa.pub")
  ssh_private_key_path = local.ssh_private_key_path

  enable_public_ip = true

  tags = {
    environment = local.parent.environment
  }
}
