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
### Storage Accounts
########################################################################
module "storage_accounts" {
  source = "../../modules/storage_account"

  for_each = var.storage_accounts

  name                = each.value.name
  resource_group_name = module.rg.rg_name
  location            = module.rg.location

  tags = var.tags

  account_kind             = each.value.account_kind
  account_tier             = each.value.account_tier
  account_replication_type = each.value.account_replication_type
  access_tier              = each.value.access_tier

  min_tls_version                   = each.value.min_tls_version
  public_network_access_enabled     = each.value.public_network_access_enabled
  shared_access_key_enabled         = each.value.shared_access_key_enabled
  allow_nested_items_to_be_public   = each.value.allow_nested_items_to_be_public
  infrastructure_encryption_enabled = each.value.infrastructure_encryption_enabled
  default_to_oauth_authentication   = each.value.default_to_oauth_authentication

  containers  = each.value.containers
  queues      = each.value.queues
  tables      = each.value.tables
  file_shares = each.value.file_shares

  blob_properties = each.value.blob_properties
  network_rules   = each.value.network_rules
  identity        = each.value.identity

  subnet_ids         = module.network.subnet_ids
  virtual_network_id = module.network.vnet_id

  create_private_dns_zones             = each.value.create_private_dns_zones
  private_dns_zone_resource_group_name = each.value.private_dns_zone_resource_group_name
  existing_private_dns_zone_ids        = each.value.existing_private_dns_zone_ids

  private_endpoints = each.value.private_endpoints
}
