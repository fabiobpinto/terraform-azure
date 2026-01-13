# Resource Group
module "rg" {
  source   = "./modules/resource_group"
  rg_name  = var.rg_name
  location = var.location
  tags     = var.tags
}

# Virtual Network
module "network" {
  source             = "./modules/virtual_network"
  rg_name            = module.rg.rg_name
  location           = module.rg.location
  vnet_name          = var.vnet_name
  vnet_address_space = var.vnet_address_space
  subnets            = var.subnets
  tags               = var.tags
}

# Network Security Group
module "nsg" {
  source = "./modules/nsg"

  for_each = var.subnets

  nsg_name = "nsg-${each.value.name}"

  rg_name  = module.rg.rg_name
  location = module.rg.location
  tags     = var.tags

  nsg_subnet_id = module.network.subnet_ids[each.key]

  nsg_rules = var.nsg_rules[each.value.rule].rules
}