output "recovery_vault_id" {
  description = "ID of the Recovery Services Vault."
  value       = azurerm_recovery_services_vault.svc_vault.id
}

output "recovery_vault_name" {
  description = "Name of the Recovery Services Vault."
  value       = azurerm_recovery_services_vault.svc_vault.name
}

output "backup_policy_id" {
  description = "ID of the Backup Policy."
  value       = azurerm_backup_policy_vm.policy.id
}

output "backup_policy_name" {
  description = "Name of the Backup Policy."
  value       = azurerm_backup_policy_vm.policy.name
}

output "protected_vm_ids" {
  description = "IDs of the protected VM backup resources."

  value = {
    for k, v in azurerm_backup_protected_vm.vm_backup :
    k => v.id
  }
}
