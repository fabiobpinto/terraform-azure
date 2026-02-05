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
  source             = "../../modules/virtual_network"
  rg_name            = module.rg.rg_name
  location           = module.rg.location
  vnet_name          = var.vnet_name
  vnet_address_space = var.vnet_address_space
  subnets            = var.subnets
  tags               = var.tags
}

########################################################################
### Network Security Group
########################################################################
module "nsg" {
  source = "../../modules/nsg"

  for_each = var.subnets

  nsg_name = "nsg-${each.value.name}"

  rg_name  = module.rg.rg_name
  location = module.rg.location
  tags     = var.tags

  nsg_subnet_id = module.network.subnet_ids[each.key]

  nsg_rules = var.nsg_rules[each.value.rule]
}

########################################################################
### Virtual Machines Linux
########################################################################
module "vms_web" {
  source   = "../../modules/vm_linux"
  location = var.location
  tags     = var.tags
  rg_name  = module.rg.rg_name

  for_each = var.vms_linux_web

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

  auto_shutdown = {
    enabled        = true
    time           = "1800"
    timezone       = "E. South America Standard Time"
    notify         = false
    notify_minutes = 30
    email          = null
  }
}

########################################################################
### LoadBalancer Public IP
########################################################################
module "public_ip_loadbalancer" {
  source = "../../modules/public_ip"

  for_each = var.loadbalancer

  rg_name  = module.rg.rg_name
  location = module.rg.location
  tags     = var.tags
  pip_name = "${each.key}-pip"
}

########################################################################
### LoadBalancer
########################################################################
module "loadbalancer" {
  source = "../../modules/loadbalancer"

  for_each = var.loadbalancer

  rg_name  = module.rg.rg_name
  location = module.rg.location
  tags     = var.tags

  lb_name                        = each.key
  sku                            = each.value.sku
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  public_ip_address_id           = module.public_ip_loadbalancer[each.key].public_ip_id
}

########################################################################
### LoadBalancer Backend Pool Association
########################################################################
resource "azurerm_network_interface_backend_address_pool_association" "lb_backend_association" {
  for_each = var.vms_linux_web

  network_interface_id    = module.vms_web[each.key].nic_id
  ip_configuration_name   = "ipconfig-${each.value.name}"
  backend_address_pool_id = module.loadbalancer[keys(var.loadbalancer)[0]].backend_pool_id
}
