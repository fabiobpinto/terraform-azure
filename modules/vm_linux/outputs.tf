output "nic_private_ip" {
  value = azurerm_network_interface.nic_linux.private_ip_address
}

output "public_ip_address" {
  value = var.enable_public_ip ? azurerm_public_ip.pip[0].ip_address : null
}

output "public_ip_id" {
  description = "ID do Public IP da VM (se existir)"
  value       = var.enable_public_ip ? azurerm_public_ip.pip[0].id : null
}