variable "subscription_id" {
  type = string
}

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

variable "vnet_name" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
}

variable "subnets" {
  type = map(object({
    name             = string
    address_prefixes = list(string)
    rule             = string
  }))
}

variable "nsg_name" {
  description = "Network Security Group name"
  type        = string
}

variable "nsg_rules" {
  description = "Regras de NSG por tipo de subnet"
  type = map(list(object({
    name      = string
    priority  = number
    direction = string

    access   = optional(string, "Allow")
    protocol = optional(string, "Tcp")

    source_port_range      = optional(string, "*")
    destination_port_range = string

    source_address_prefix      = optional(string, "*")
    destination_address_prefix = optional(string, "*")
  })))
}

variable "admin_username" {
  type        = string
  description = "The admin username for the Linux virtual machine."
}

variable "admin_pass" {
  type        = string
  sensitive   = true
  description = "The admin password for the Linux virtual machine."
}

variable "vms_linux_web" {
  type = map(object({
    admin_username                  = string
    name                            = string
    computer_name                   = string
    size                            = string
    disable_password_authentication = bool

    enable_public_ip = optional(bool)
    pip_name         = optional(string)

    os_disk = object({
      caching              = string
      storage_account_type = string
      disk_size_gb         = number
    })

    source_image_reference = object({
      offer     = string
      publisher = string
      sku       = string
      version   = string
    })

    nic_ip_configuration_name = string
    subnet_name               = string

    nic_info = object({
      private_ip_address            = string
      private_ip_address_allocation = string
    })

    auto_shutdown = optional(object({
      time           = string
      timezone       = string
      notify         = bool
      notify_minutes = number
      email          = string
    }))

  }))
  description = "Configuration object for the Linux virtual machine."
}

variable "backup_policies" {
  description = "Recovery Services Vaults and VM backup configuration."
  type = map(object({

    recovery_vault = object({
      name                = string
      sku                 = optional(string, "Standard")
      soft_delete_enabled = bool
      storage_mode_type   = optional(string, "GeoRedundant")
      # instant_restore_retention_days = optional(number, 5)
    })

    backup_policy = object({
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

    # source_vm_id = list(string)
  }))
}
