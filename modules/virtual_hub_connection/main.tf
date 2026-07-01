resource "azurerm_virtual_hub_connection" "vhub_connection" {
  name                      = var.vhub_connection_name
  virtual_hub_id            = var.virtual_hub_id
  remote_virtual_network_id = var.remote_virtual_network_id
}
