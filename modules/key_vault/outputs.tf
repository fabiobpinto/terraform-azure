output "id" {
  description = "Key Vault resource ID."
  value       = azurerm_key_vault.this.id
}

output "name" {
  description = "Key Vault name."
  value       = azurerm_key_vault.this.name
}

output "vault_uri" {
  description = "Key Vault URI."
  value       = azurerm_key_vault.this.vault_uri
}

output "private_endpoints" {
  description = "Map of private endpoint key → object (id, network_interface_id, custom_dns_configs). Empty when no endpoints configured."
  value = {
    for k, v in azurerm_private_endpoint.this : k => {
      id                   = v.id
      network_interface_id = try(v.network_interface[0].id, null)
      custom_dns_configs   = v.custom_dns_configs
    }
  }
}
