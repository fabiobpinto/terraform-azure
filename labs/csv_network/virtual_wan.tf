########################################################################
### Virtual WAN
########################################################################
module "virtual_wan" {
  source = "../../modules/virtual_wan"

  for_each = local.virtual_wan

  rg_name  = module.rg.rg_name
  location = module.rg.location
  tags     = local.tags

  wan_name = each.value.name
}

########################################################################
### Virtual Hub
########################################################################
module "virtual_hub" {
  source = "../../modules/virtual_hub"

  for_each = local.virtual_hubs

  rg_name  = module.rg.rg_name
  location = module.rg.location
  tags     = local.tags

  vhub_name      = each.value.name
  address_prefix = each.value.address_prefix
  virtual_wan_id = module.virtual_wan[each.value.wan_name].virtual_wan_id
}

########################################################################
### Virtual Hub Connections
########################################################################
module "virtual_hub_connection" {
  source                    = "../../modules/virtual_hub_connection"
  for_each                  = local.virtual_hub_connections
  vhub_connection_name      = each.value.name
  virtual_hub_id            = module.virtual_hub[each.value.vhub_name].virtual_hub_id
  remote_virtual_network_id = module.network[each.value.vnet_name].vnet_id
}


########################################################################
### Virtual Hub Route Tables
########################################################################
module "virtual_hub_route_table" {
  source   = "../../modules/virtual_hub_route_table"
  for_each = local.virtual_hub_route_tables

  virtual_hub_id     = module.virtual_hub[each.value.vhub_name].virtual_hub_id
  route_table_name   = each.value.route_table_name
  route_table_labels = each.value.route_table_labels
  routes = [
    for route in each.value.routes : {
      name              = route.name
      destinations_type = route.destinations_type
      destinations      = route.destinations
      next_hop_type     = route.next_hop_type
      next_hop          = lookup(local.resource_registry, "${route.next_hop_resource_type}:${route.next_hop_resource_name}", null)
    }
  ]
}
