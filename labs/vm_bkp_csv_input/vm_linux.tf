########################################################################
### Virtual Machines Linux
########################################################################
module "vms_linux" {
  source   = "../../modules/vm_linux"
  rg_name  = module.rg.rg_name
  location = module.rg.location
  tags     = local.tags

  for_each = local.vms_linux

  enable_public_ip = try(each.value.enable_public_ip, false)

  vm_linux = {
    admin_username                  = each.value.admin_username
    admin_pass                      = var.admin_pass
    disable_password_authentication = each.value.disable_password_authentication
    vm_name                         = each.value.name
    computer_name                   = each.value.computer_name
    vm_size                         = each.value.size
    os_disk = {
      # caching              = each.value.os_disk.caching
      storage_account_type = each.value.os_disk.storage_account_type
      disk_size_gb         = each.value.os_disk.disk_size_gb
    }
    source_image_reference = {
      publisher = each.value.source_image_reference.publisher
      offer     = each.value.source_image_reference.offer
      sku       = each.value.source_image_reference.sku
      version   = each.value.source_image_reference.version
    }
  }

  nic_info = {
    name = "nic-${each.value.name}"
    ip_configuration = {
      name                          = "ipconfig-${each.value.name}"
      subnet_id                     = module.network.subnet_ids[each.value.subnet_name]
      private_ip_address_allocation = each.value.nic_info.private_ip_address_allocation
      private_ip_address            = each.value.nic_info.private_ip_address
    }
  }

  auto_shutdown = try(each.value.auto_shutdown, null)

}
