resource "azurerm_resource_group" "rg_main" {
  name     = var.rg_name
  location = var.location
  tags     = var.tags
}