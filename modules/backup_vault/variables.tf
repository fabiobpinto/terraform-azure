variable "rg_name" {
  type        = string
  description = "The name of the resource group."
}

variable "location" {
  type        = string
  description = "The Azure region where the resources will be deployed."
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource group."
}

variable "source_vm_id" {
  description = "ID of the Virtual Machine to be protected."
  type        = map(string)
}

variable "recovery_vault" {
  description = "Recovery Services Vault configuration."

  type = object({
    name                = string
    sku                 = optional(string, "Standard")
    soft_delete_enabled = bool
    storage_mode_type   = optional(string, "GeoRedundant")
    # instant_restore_retention_days = optional(number, 5)
  })
}

variable "backup_policy" {
  description = "Virtual Machine backup policy."

  type = object({
    name     = string
    timezone = string

    backup = object({
      frequency     = string
      time          = string
      weekdays      = optional(list(string))
      hour_interval = optional(number)
      hour_duration = optional(number)
    })

    retention_daily = object({
      count = number
    })

    retention_weekly = object({
      count    = number
      weekdays = list(string)
    })

    retention_monthly = object({
      count    = number
      weekdays = list(string)
      weeks    = list(string)
    })

    retention_yearly = object({
      count    = number
      weekdays = list(string)
      weeks    = list(string)
      months   = list(string)
    })
  })
}
