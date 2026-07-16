########################################################################
### Virtual Network
########################################################################
module "network" {
  source = "../../modules/virtual_network"

  for_each = local.networks

  rg_name  = module.rg.rg_name
  location = module.rg.location
  tags     = local.tags

  vnet_name          = each.value.vnet_name
  vnet_address_space = each.value.vnet_address_space

  subnets = each.value.subnets

}
