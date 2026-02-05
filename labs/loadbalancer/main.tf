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
  source = "../../modules/nsg"
  rg_name  = module.rg.rg_name
  location = module.rg.location
  tags     = var.tags

  for_each = var.subnets

  nsg_name = "nsg-${each.value.name}"
  nsg_subnet_id = module.network.subnet_ids[each.key]
  nsg_rules = var.nsg_rules[each.value.rule]
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
    time           = "1900"
    timezone       = "E. South America Standard Time"
    notify         = false
    notify_minutes = 30
    email          = null
  }
}

########################################################################
### Virtual Machines Linux Ansible
########################################################################
module "vms_ansible" {
  source   = "../../modules/vm_linux"
  rg_name  = module.rg.rg_name
  location = module.rg.location
  tags     = var.tags

  for_each = var.vms_linux_ansible

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
      subnet_id                     = module.network.subnet_ids["ansible"]
      private_ip_address_allocation = each.value.nic_info.private_ip_address_allocation
      private_ip_address            = each.value.nic_info.private_ip_address
    }
  }

  auto_shutdown = {
    enabled        = true
    time           = "1900"
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
  rg_name  = module.rg.rg_name
  location = module.rg.location
  tags     = var.tags

  for_each = var.loadbalancer_public

  pip_name = "pip-${each.value.name}"
}

########################################################################
### LoadBalancer Public
########################################################################
module "loadbalancer_public" {
  source   = "../../modules/loadbalancer"
  rg_name  = module.rg.rg_name
  location = module.rg.location
  tags     = var.tags

  for_each = var.loadbalancer_public

  lb = {
    name     = each.value.name
    sku      = each.value.sku
    sku_tier = each.value.sku_tier

    frontend_ip_configuration = {
      frontendip = {
        name                 = "${each.value.frontend_ip_configuration.frontendip.name}-${each.value.name}"
        public_ip_address_id = module.public_ip_loadbalancer[each.key].public_ip_id
      }
    }
  }

  lb_probes = each.value.lb_probes

  lb_rules = {
    for rule_key, rule in each.value.lb_rules :
    rule_key => merge(
      rule,
      {
        frontend_ip_configuration_name = "${each.value.frontend_ip_configuration.frontendip.name}-${each.value.name}"
      }
    )
  }

  lb_nat_rules = {
    for nat_key, nat in lookup(each.value, "lb_nat_rules", {}) :
    nat_key => {
      name                           = nat.name
      protocol                       = nat.protocol
      frontend_port                  = nat.frontend_port
      backend_port                   = nat.backend_port
      frontend_ip_configuration_name = "${each.value.frontend_ip_configuration.frontendip.name}-${each.value.name}"
    }
  }

  nic_nat_rule_associations = {
    for nat_key, nat in lookup(each.value, "lb_nat_rules", {}) :
    nat_key => {
      network_interface_id  = module.vms_web[nat.target_vm].nic_id
      ip_configuration_name = module.vms_web[nat.target_vm].nic_ip_configuration_name
      nat_rule_key          = nat_key
    }
  }

  nic_be_pool_associations = {
    for vm_key, vm in module.vms_web :
    vm_key => {
      network_interface_id  = vm.nic_id
      ip_configuration_name = vm.nic_ip_configuration_name
    }
  }
}

########################################################################
### LoadBalancer Private
########################################################################
module "loadbalancer_private" {
  source   = "../../modules/loadbalancer"
  rg_name  = module.rg.rg_name
  location = module.rg.location
  tags     = var.tags

  for_each = var.loadbalancer_private

  lb = {
    name     = each.value.name
    sku      = each.value.sku
    sku_tier = each.value.sku_tier

    frontend_ip_configuration = {
      frontendip = {
        name                          = "${each.value.frontend_ip_configuration.frontendip.name}-${each.value.name}"
        private_ip_address_allocation = each.value.frontend_ip_configuration.frontendip.private_ip_address_allocation
        private_ip_address            = each.value.frontend_ip_configuration.frontendip.private_ip_address
        subnet_id                     = module.network.subnet_ids["loadbalancer"]
      }
    }
  }
  lb_probes = each.value.lb_probes

  lb_rules = {
    for rule_key, rule in each.value.lb_rules :
    rule_key => merge(
      rule,
      {
        frontend_ip_configuration_name = "${each.value.frontend_ip_configuration.frontendip.name}-${each.value.name}"
      }
    )
  }

  nic_be_pool_associations = {
    for vm_key, vm in module.vms_web :
    vm_key => {
      network_interface_id  = vm.nic_id
      ip_configuration_name = vm.nic_ip_configuration_name
    }
  }
}