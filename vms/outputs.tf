output "vm_ids" {
  value = { for key, vm in azurerm_linux_virtual_machine.vm : key => vm.id }
}

output "vm_names" {
  value = { for key, vm in azurerm_linux_virtual_machine.vm : key => vm.name }
}

output "private_ips" {
  value = { for key, nic in azurerm_network_interface.vm_nic : key => nic.private_ip_address }
}

output "public_ips" {
  value = var.enable_public_ip ? { for key, pip in azurerm_public_ip.vm_pip : key => pip.ip_address } : {}
}

output "admin_username" {
  value = var.admin_username
}
