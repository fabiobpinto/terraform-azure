output "virtual_hub_route_table_id" {
  description = "ID of the Virtual Hub Route Table."
  value       = azurerm_virtual_hub_route_table.vhub_route_table.id
}

output "virtual_hub_route_table_name" {
  description = "Name of the Virtual Hub Route Table."
  value       = azurerm_virtual_hub_route_table.vhub_route_table.name
}
