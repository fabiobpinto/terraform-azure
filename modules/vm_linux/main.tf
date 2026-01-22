resource "azurerm_network_interface" "nic_linux" {
  name                = "linux-nic-${var.vm_linux.vm_name}"
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal-ip-${var.vm_linux.vm_name}"
    subnet_id                     = var.nic_info.ip_configuration.subnet_id
    private_ip_address_allocation = var.nic_info.ip_configuration.private_ip_address_allocation
    private_ip_address            = var.nic_info.ip_configuration.private_ip_address
  }
}

resource "azurerm_linux_virtual_machine" "vm_linux" {
  name                = var.vm_linux.vm_name
  resource_group_name = var.rg_name
  location            = var.location
  size                = var.vm_linux.vm_size
  admin_username      = var.vm_linux.admin_username
  admin_password      = var.vm_linux.admin_pass
  disable_password_authentication = var.vm_linux.disable_password_authentication
  network_interface_ids = [
    azurerm_network_interface.nic_linux.id
  ]

  admin_ssh_key {
    username   = var.vm_linux.admin_username
    public_key = file("${path.root}/ssh-keys/terraform-azure.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.vm_linux.source_image_reference.publisher
    offer     = var.vm_linux.source_image_reference.offer
    sku       = var.vm_linux.source_image_reference.sku
    version   = var.vm_linux.source_image_reference.version
  }

  lifecycle {
    ignore_changes = [
      admin_password
    ]
  }

tags           = var.tags

}
