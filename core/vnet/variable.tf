variable "prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "location" {
  description = "Azure region for the virtual network"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group where the virtual network will be created"
  type        = string
}

variable "address_space" {
  description = "Address space for the virtual network (e.g., ['10.0.0.0/16'])"
  type        = list(string)
}

variable "subnet_address_prefix" {
  description = "Subnet address prefix"
  type        = list(string)
}

variable "ssh_source_address_prefixes" {
  description = "Source address prefixes allowed to SSH into the VMs"
  type        = list(string)
  default     = ["*"]
}
