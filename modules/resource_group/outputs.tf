output "rg_name" {
  value       = azurerm_resource_group.rg_main.name
  description = "The name of the resource group."
}
output "location" {
  value       = azurerm_resource_group.rg_main.location
  description = "The location of the resource group."
}

output "rg_id" {
  value = azurerm_resource_group.rg_main.id
  description = "The id of the resource group"
}