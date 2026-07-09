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
  auto_shutdown = try(each.value.auto_shutdown, null)
}

########################################################################
### Key Vaults
########################################################################
module "key_vault" {
  source                        = "../../modules/key_vault"
  for_each                      = var.key_vaults
  name                          = each.value.name
  resource_group_name           = module.rg.rg_name
  location                      = module.rg.location
  network_acls                  = try(each.value.network_acls, null)
  public_network_access_enabled = try(each.value.public_network_access_enabled, false)
  allow_public_only             = try(each.value.allow_public_only, false)
  secrets = each.key == "kv-linuxweb01" ? [
    {
      name  = "admin-password"
      value = var.admin_pass
    }
  ] : []
  private_endpoints = {
    for pe_key, pe in try(each.value.private_endpoints, {}) :
    pe_key => {
      name                           = pe.name
      subnet_resource_id             = module.network.subnet_ids[pe.subnet_name]
      private_ip_address             = try(pe.private_ip_address, null)
      private_dns_zone_resource_ids  = try(pe.private_dns_zone_resource_ids, [])
      application_security_group_ids = try(pe.application_security_group_ids, [])
    }
  }
  tags = var.tags
}
