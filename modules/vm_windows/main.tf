resource "azurerm_public_ip" "pip" {
  count = var.enable_public_ip ? 1 : 0

  name                = "pip-${var.vm_windows.vm_name}"
  resource_group_name = var.rg_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_network_interface" "nic_windows" {
  name                = "windows-nic-${var.vm_windows.vm_name}"
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal-ip-${var.vm_windows.vm_name}"
    subnet_id                     = var.nic_info.ip_configuration.subnet_id
    private_ip_address_allocation = var.nic_info.ip_configuration.private_ip_address_allocation
    private_ip_address            = var.nic_info.ip_configuration.private_ip_address

    public_ip_address_id = var.enable_public_ip ? azurerm_public_ip.pip[0].id : null

  }
}

resource "azurerm_network_interface_application_security_group_association" "asg" {
  for_each = toset(var.application_security_group_ids)

  network_interface_id          = azurerm_network_interface.nic_windows.id
  application_security_group_id = each.value
}

resource "azurerm_windows_virtual_machine" "vm_windows" {
  name                = var.vm_windows.vm_name
  computer_name       = var.vm_windows.computer_name
  resource_group_name = var.rg_name
  location            = var.location
  size                = var.vm_windows.vm_size
  admin_username      = var.vm_windows.admin_username
  admin_password      = var.vm_windows.admin_password

  network_interface_ids = [
    azurerm_network_interface.nic_windows.id
  ]

  os_disk {
    caching              = var.vm_windows.os_disk.caching
    storage_account_type = var.vm_windows.os_disk.storage_account_type
    disk_size_gb         = var.vm_windows.os_disk.disk_size_gb
  }

  source_image_reference {
    publisher = var.vm_windows.source_image_reference.publisher
    offer     = var.vm_windows.source_image_reference.offer
    sku       = var.vm_windows.source_image_reference.sku
    version   = var.vm_windows.source_image_reference.version
  }

  lifecycle {
    ignore_changes = [
      admin_password,
      custom_data
    ]
  }

  tags = var.tags

}


resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdown" {
  count = var.auto_shutdown != null ? 1 : 0

  virtual_machine_id    = azurerm_windows_virtual_machine.vm_windows.id
  location              = var.location
  enabled               = true
  daily_recurrence_time = var.auto_shutdown.time
  timezone              = var.auto_shutdown.timezone

  notification_settings {
    enabled         = var.auto_shutdown.notify
    time_in_minutes = var.auto_shutdown.notify_minutes
    email           = var.auto_shutdown.email
  }
}
