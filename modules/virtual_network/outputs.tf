########################################################################
### Virtual Network Outputs
########################################################################
output "vnet_id" {
  description = "The ID of the Virtual Network."
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "The name of the Virtual Network."
  value       = azurerm_virtual_network.vnet.name
}

########################################################################
### Subnet Outputs
########################################################################
output "subnet_ids" {
  description = "Map of subnet names and IDs."
  value = {
    for subnet_name, subnet in azurerm_subnet.subnets :
    subnet_name => subnet.id
  }
}
