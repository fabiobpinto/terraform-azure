output "nic_private_ip" {
  value = azurerm_network_interface.nic_linux.private_ip_address
}

output "nic_id" {
  value = azurerm_network_interface.nic_linux.id
}
