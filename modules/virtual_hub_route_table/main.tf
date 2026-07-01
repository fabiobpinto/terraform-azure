resource "azurerm_virtual_hub_route_table" "vhub_route_table" {
  name           = var.route_table_name
  virtual_hub_id = var.virtual_hub_id
  labels         = var.route_table_labels

  dynamic "route" {
    for_each = var.routes

    content {
      name              = route.value.name
      destinations_type = route.value.destinations_type
      destinations      = route.value.destinations
      next_hop_type     = route.value.next_hop_type
      next_hop          = route.value.next_hop
    }
  }
}
