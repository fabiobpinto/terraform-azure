########################################################################
### Virtual Network
########################################################################
module "network" {
  source   = "../../modules/virtual_network"
  rg_name  = module.rg.rg_name
  location = module.rg.location
  tags     = local.tags

  vnet_name          = local.network.vnet_name
  vnet_address_space = local.network.vnet_address_space
  subnets            = local.network.subnets
}
