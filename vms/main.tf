resource "azurerm_public_ip" "vm_pip" {
  for_each = var.enable_public_ip ? var.vms : {}

  name                = "${each.value.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "vm_nic" {
  for_each = var.vms

  name                = "${each.value.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.enable_public_ip ? azurerm_public_ip.vm_pip[each.key].id : null
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each = var.vms

  name                            = each.value.name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = each.value.size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  custom_data                     = filebase64("${path.module}/cloud-init.yaml")
  tags                            = var.tags

  network_interface_ids = [
    azurerm_network_interface.vm_nic[each.key].id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  # Block until SSH is reachable so Ansible can bootstrap right after apply
  connection {
    type        = "ssh"
    host        = var.enable_public_ip ? azurerm_public_ip.vm_pip[each.key].ip_address : azurerm_network_interface.vm_nic[each.key].private_ip_address
    user        = var.admin_username
    private_key = file(var.ssh_private_key_path)
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = ["echo ssh ready"]
  }
}
