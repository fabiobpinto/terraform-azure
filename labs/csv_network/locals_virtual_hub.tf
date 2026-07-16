locals {
  ###############################################################
  # Virtual WAN CSV
  ###############################################################
  virtual_wan_csv = csvdecode(file("${path.module}/data/04-virtual_wan.csv"))
  virtual_wan = {
    for wan in local.virtual_wan_csv :
    wan.wan_name => {
      name = wan.wan_name
      type = wan.type
    }
  }

  ###############################################################
  # Virtual Hub CSV
  ###############################################################
  virtual_hub_csv = csvdecode(file("${path.module}/data/05-virtual_hub.csv"))

  virtual_hubs = {
    for hub in local.virtual_hub_csv :
    hub.vhub_name => {
      name           = hub.vhub_name
      address_prefix = hub.address_prefix
      wan_name       = hub.wan_name
    }
  }

  ###############################################################
  # Virtual Hub Connections CSV
  ###############################################################
  virtual_hub_connections_csv = csvdecode(file("${path.module}/data/06-virtual_hub_connections.csv"))

  virtual_hub_connections = {
    for connection in local.virtual_hub_connections_csv :
    connection.connection_name => {
      name      = connection.connection_name
      vhub_name = connection.vhub_name
      vnet_name = connection.vnet_name
    }
  }

  ###############################################################
  # Virtual Hub Route Tables CSV
  ###############################################################
  virtual_hub_route_table_csv = csvdecode(file("${path.module}/data/07-virtual_hub_route_tables.csv"))

  ###############################################################
  # Virtual Hub Route Tables
  ###############################################################
  virtual_hub_route_tables = {
    for table_name in distinct([
      for item in local.virtual_hub_route_table_csv :
      item.route_table_name
    ]) :
    table_name => {
      vhub_name = [
        for item in local.virtual_hub_route_table_csv :
        item.vhub_name
        if item.route_table_name == table_name
      ][0]
      route_table_name = table_name
      route_table_labels = split(
        ";",
        [
          for item in local.virtual_hub_route_table_csv :
          item.labels
          if item.route_table_name == table_name
        ][0]
      )

      routes = [
        for route in local.virtual_hub_route_table_csv : {
          name              = route.route_name
          destinations_type = route.destinations_type
          destinations = split(
            ";",
            route.destinations
          )
          next_hop_type          = route.next_hop_type
          next_hop_resource_type = route.next_hop_resource_type
          next_hop_resource_name = route.next_hop_resource_name
        }
        if route.route_table_name == table_name
      ]
    }
  }
}
