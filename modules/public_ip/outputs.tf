output "public_ip_address" {
  description = "The allocated public IP address."
  value       = azurerm_public_ip.pip.ip_address
}

output "public_ip_id" {
  value       = azurerm_public_ip.pip.id
  description = "The ID of the public IP address."
}