resource "azurerm_virtual_hub" "virtual_hub" {
  name                = var.vhub_name
  resource_group_name = var.rg_name
  location            = var.location
  virtual_wan_id      = var.virtual_wan_id
  address_prefix      = var.address_prefix

  tags = var.tags

  timeouts {
    create = "60m"
    delete = "60m"
    update = "60m"
  }

}
