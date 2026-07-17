resource "azurerm_recovery_services_vault" "svc_vault" {
  name                = var.recovery_vault.name
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = var.recovery_vault.sku
  soft_delete_enabled = var.recovery_vault.soft_delete_enabled
  storage_mode_type   = var.recovery_vault.storage_mode_type
}

resource "azurerm_backup_policy_vm" "policy" {
  name                = var.backup_policy.name
  resource_group_name = var.rg_name
  recovery_vault_name = azurerm_recovery_services_vault.svc_vault.name

  timezone = var.backup_policy.timezone

  backup {
    frequency     = var.backup_policy.backup.frequency
    time          = var.backup_policy.backup.time
    weekdays      = var.backup_policy.backup.frequency == "Weekly" ? var.backup_policy.backup.weekdays : null
    hour_interval = var.backup_policy.backup.frequency == "Hourly" ? var.backup_policy.backup.hour_interval : null
    hour_duration = var.backup_policy.backup.frequency == "Hourly" ? var.backup_policy.backup.hour_duration : null
  }

  dynamic "retention_daily" {
    for_each = var.backup_policy.backup.frequency == "Daily" ? [1] : []
    content {
      count = var.backup_policy.retention_daily.count
    }
  }

  dynamic "retention_weekly" {
    for_each = contains(["Daily", "Weekly"], var.backup_policy.backup.frequency) ? [1] : []
    content {
      count    = var.backup_policy.retention_weekly.count
      weekdays = var.backup_policy.retention_weekly.weekdays
    }
  }

  dynamic "retention_monthly" {
    for_each = contains(["Daily", "Weekly"], var.backup_policy.backup.frequency) ? [1] : []
    content {
      count    = var.backup_policy.retention_monthly.count
      weekdays = var.backup_policy.retention_monthly.weekdays
      weeks    = var.backup_policy.retention_monthly.weeks
    }
  }

  dynamic "retention_yearly" {
    for_each = contains(["Daily", "Weekly"], var.backup_policy.backup.frequency) ? [1] : []
    content {
      count    = var.backup_policy.retention_yearly.count
      weekdays = var.backup_policy.retention_yearly.weekdays
      weeks    = var.backup_policy.retention_yearly.weeks
      months   = var.backup_policy.retention_yearly.months
    }
  }
}

resource "azurerm_backup_protected_vm" "vm_backup" {
  for_each = var.source_vm_id

  resource_group_name = var.rg_name
  recovery_vault_name = azurerm_recovery_services_vault.svc_vault.name

  source_vm_id     = each.value
  backup_policy_id = azurerm_backup_policy_vm.policy.id
}
