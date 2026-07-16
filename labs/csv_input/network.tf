########################################################################
### Virtual Network
########################################################################
module "network" {
  source   = "../../modules/virtual_network"
  rg_name  = module.rg.rg_name
  location = module.rg.location
  tags     = local.tags

  vnet_name          = local.csv_virtual_network.vnet_name
  vnet_address_space = local.csv_virtual_network.vnet_address_space
  subnets            = local.csv_virtual_network.subnets
}
