########################################################################
### Resource Group
########################################################################
module "rg" {
  source   = "../../modules/resource_group"
  rg_name  = var.rg_name
  location = var.location
  tags     = var.tags
}

########################################################################
### Virtual Network
########################################################################
module "network" {
  source   = "../../modules/virtual_network"
  rg_name  = module.rg.rg_name
  location = module.rg.location
  tags     = var.tags

  vnet_name          = var.vnet_name
  vnet_address_space = var.vnet_address_space
  subnets            = var.subnets
}

########################################################################
### Network Security Group
########################################################################
module "nsg" {
  source   = "../../modules/nsg"
  rg_name  = module.rg.rg_name
  location = module.rg.location
  tags     = var.tags

  for_each = var.subnets

  nsg_name      = "nsg-${each.value.name}"
  nsg_subnet_id = module.network.subnet_ids[each.key]
  nsg_rules     = var.nsg_rules[each.value.rule]
}

########################################################################
### Virtual Machines Linux
########################################################################
module "vms_web" {
  source   = "../../modules/vm_linux"
  rg_name  = module.rg.rg_name
  location = module.rg.location
  tags     = var.tags

  for_each = var.vms_linux_web

  enable_public_ip = try(each.value.enable_public_ip, false)

  vm_linux = {
    admin_username                  = each.value.admin_username
    admin_pass                      = var.admin_pass
    disable_password_authentication = each.value.disable_password_authentication
    vm_name                         = each.value.name
    computer_name                   = each.value.computer_name
    vm_size                         = each.value.size

    os_disk = {
      caching              = each.value.os_disk.caching
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
      subnet_id                     = module.network.subnet_ids["web"]
      private_ip_address_allocation = each.value.nic_info.private_ip_address_allocation
      private_ip_address            = each.value.nic_info.private_ip_address
    }
  }
  enable_auto_shutdown = each.value.enable_auto_shutdown
  auto_shutdown        = each.value.enable_auto_shutdown ? each.value.auto_shutdown : null
}


# ########################################################################
# ### Backup
# ########################################################################
module "backup_daily" {
  source = "../../modules/backup_vault"

  rg_name  = module.rg.rg_name
  location = module.rg.location

  recovery_vault = var.backup_policies["daily"].recovery_vault
  backup_policy  = var.backup_policies["daily"].backup_policy

  source_vm_id = {
    linuxweb01 = module.vms_web["linuxweb01"].vm_id,
    linuxweb03 = module.vms_web["linuxweb02"].vm_id
  }
  tags = var.tags
}

module "backup_weekly" {
  source = "../../modules/backup_vault"

  rg_name  = module.rg.rg_name
  location = module.rg.location

  recovery_vault = var.backup_policies["weekly"].recovery_vault
  backup_policy  = var.backup_policies["weekly"].backup_policy

  source_vm_id = {
    linuxweb02 = module.vms_web["linuxweb03"].vm_id
  }
  tags = var.tags
}
