variable "resource_group_name" {
  description = "Name of the resource group where the VMs will be created"
  type        = string
}

variable "location" {
  description = "Azure region for the VMs"
  type        = string
}

variable "subnet_id" {
  description = "Subnet id where the VM NICs will be attached"
  type        = string
}

variable "vms" {
  description = "Map of VMs to create"
  type = map(object({
    name = string
    size = string
    vm_tags = map(string)
  }))
}

variable "admin_username" {
  description = "Admin username for the VMs"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key content used to authenticate to the VMs"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key used by Terraform/Ansible to connect to the VMs"
  type        = string
  sensitive   = true
}

variable "enable_public_ip" {
  description = "Whether to assign a public IP to each VM so it can be reached over SSH"
  type        = bool
  default     = true
}

variable "os_disk_storage_account_type" {
  description = "Storage account type for the OS disk"
  type        = string
  default     = "Standard_LRS"
}

variable "image_publisher" {
  description = "Source image publisher"
  type        = string
  default     = "Canonical"
}

variable "image_offer" {
  description = "Source image offer"
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  description = "Source image sku"
  type        = string
  default     = "22_04-lts"
}

variable "image_version" {
  description = "Source image version"
  type        = string
  default     = "latest"
}

variable "tags" {
  description = "Tags to apply to the VM resources"
  type        = map(string)
  default     = {}
}
