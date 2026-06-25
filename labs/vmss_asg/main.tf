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
### Application Security Group
########################################################################
module "asg" {
  source = "../../modules/asg"

  for_each = var.asgs

  asg_name = each.value.name

  rg_name  = module.rg.rg_name
  location = module.rg.location
  tags     = var.tags

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

  application_security_group_ids = {
    for asg_key, asg in module.asg : asg_key => asg.id
  }

  nsg_rules = var.nsg_rules[each.value.rule]
}




########################################################################
### LoadBalancer Public IP
########################################################################
module "public_ip_loadbalancer" {
  source   = "../../modules/public_ip"
  rg_name  = module.rg.rg_name
  location = module.rg.location
  tags     = var.tags

  for_each = var.loadbalancer_public

  pip_name = "pip-${each.value.name}"
}

# ########################################################################
# ### LoadBalancer Public
# ########################################################################
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

}

########################################################################
### Virtual Machine Scale Set (VMSS)
########################################################################
module "vmss_linux" {
  for_each = var.vmss_linux

  source = "../../modules/vmss_linux"

  rg_name  = var.rg_name
  location = var.location
  tags     = var.tags

  subnet_id = module.network.subnet_ids["vmss"]

  application_security_group_ids = [
    module.asg["web"].id
  ]

  load_balancer_backend_address_pool_ids = [
    module.loadbalancer_public["prd-loadbalancer01"].backend_pool_id
  ]

  vmss_linux = each.value

}
