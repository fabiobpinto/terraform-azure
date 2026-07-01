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
### Virtual WAN
########################################################################
module "virtual_wan" {
  source   = "../../modules/virtual_wan"
  rg_name  = module.rg.rg_name
  location = module.rg.location
  tags     = var.tags

  wan_name = var.wan_name
}


########################################################################
### Virtual Hub
########################################################################
module "virtual_hub" {
  source   = "../../modules/virtual_hub"
  rg_name  = module.rg.rg_name
  location = module.rg.location
  tags     = var.tags

  vhub_name      = var.vhub_name
  virtual_wan_id = module.virtual_wan.virtual_wan_id
  address_prefix = var.hub_address_prefix
}

########################################################################
### Virtual Hub Connection
########################################################################
module "vhub_connection" {
  source                    = "../../modules/virtual_hub_connection"
  vhub_connection_name      = "${var.vhub_name}-connection"
  virtual_hub_id            = module.virtual_hub.virtual_hub_id
  remote_virtual_network_id = module.network.vnet_id
}

module "virtual_hub_route_table" {
  source             = "../../modules/virtual_hub_route_table"
  route_table_name   = var.route_table_name
  virtual_hub_id     = module.virtual_hub.virtual_hub_id
  route_table_labels = var.route_table_labels
  routes = [
    for route in var.routes : {
      name              = route.name
      destinations_type = route.destinations_type
      destinations      = route.destinations
      next_hop_type     = route.next_hop_type
      next_hop          = module.vhub_connection.virtual_hub_connection_id
    }
  ]
}
