output "id" {
  description = "ID do Storage Account."
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "Nome do Storage Account."
  value       = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  description = "Endpoint primário Blob."
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_file_endpoint" {
  description = "Endpoint primário File."
  value       = azurerm_storage_account.this.primary_file_endpoint
}

output "container_ids" {
  description = "IDs dos containers criados."
  value = {
    for key, container in azurerm_storage_container.this :
    key => container.id
  }
}

output "file_share_ids" {
  description = "IDs dos Azure File Shares criados."
  value = {
    for key, share in azurerm_storage_share.this :
    key => share.id
  }
}

output "file_share_names" {
  description = "Nomes dos Azure File Shares criados."
  value = {
    for key, share in azurerm_storage_share.this :
    key => share.name
  }
}

output "queue_ids" {
  description = "IDs das queues criadas."
  value = {
    for key, queue in azurerm_storage_queue.this :
    key => queue.id
  }
}

output "table_ids" {
  description = "IDs das tables criadas."
  value = {
    for key, table in azurerm_storage_table.this :
    key => table.id
  }
}

output "private_endpoint_ids" {
  description = "IDs dos Private Endpoints criados."
  value = {
    for key, pe in azurerm_private_endpoint.this :
    key => pe.id
  }
}

output "private_endpoint_names" {
  description = "Nomes dos Private Endpoints criados."
  value = {
    for key, pe in azurerm_private_endpoint.this :
    key => pe.name
  }
}

output "private_dns_zone_ids" {
  description = "IDs das Private DNS Zones criadas ou usadas."
  value       = local.private_dns_zone_ids
}

output "storage_account" {
  description = "Resumo do Storage Account."
  value = {
    id                            = azurerm_storage_account.this.id
    name                          = azurerm_storage_account.this.name
    resource_group_name           = azurerm_storage_account.this.resource_group_name
    location                      = azurerm_storage_account.this.location
    public_network_access_enabled = azurerm_storage_account.this.public_network_access_enabled
  }
}
