# resource "azurerm_network_interface_application_security_group_association" "asg" {
#   for_each = toset(var.application_security_group_ids)

#   network_interface_id          = azurerm_network_interface.nic_linux.id
#   application_security_group_id = each.value
# }

resource "azurerm_linux_virtual_machine_scale_set" "vmss_linux" {
  name                = var.vmss_linux.vm_name
  resource_group_name = var.rg_name
  location            = var.location

  sku       = var.vmss_linux.sku
  instances = var.vmss_linux.instances

  admin_username = var.vmss_linux.admin_username

  custom_data = base64encode(file("${path.module}/cloud-init/cloud-init.yml"))

  admin_ssh_key {
    username   = var.vmss_linux.admin_username
    public_key = file("${path.module}/ssh-keys/terraform-azure.pub")
  }


  source_image_reference {
    publisher = var.vmss_linux.source_image_reference.publisher
    offer     = var.vmss_linux.source_image_reference.offer
    sku       = var.vmss_linux.source_image_reference.sku
    version   = var.vmss_linux.source_image_reference.version
  }

  os_disk {
    caching              = var.vmss_linux.os_disk.caching
    storage_account_type = var.vmss_linux.os_disk.storage_account_type
    disk_size_gb         = var.vmss_linux.os_disk.disk_size_gb
  }

  network_interface {
    name    = "interface-${var.vmss_linux.vm_name}"
    primary = true

    ip_configuration {
      name      = "ipconfig-${var.vmss_linux.vm_name}"
      primary   = true
      subnet_id = var.subnet_id

      application_security_group_ids = var.application_security_group_ids

      load_balancer_backend_address_pool_ids = var.load_balancer_backend_address_pool_ids
    }
  }

  tags = var.tags
}
