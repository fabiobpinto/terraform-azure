resource "azurerm_virtual_wan" "virtual_wan" {
  name                = var.wan_name
  location            = var.location
  resource_group_name = var.rg_name

  type = "Standard" # Basic ou Standard

  tags = var.tags
}
