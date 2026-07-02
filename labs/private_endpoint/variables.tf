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



variable "storage_accounts" {
  description = "Mapa de Storage Accounts."
  type = map(object({
    name                              = string
    account_kind                      = optional(string, "StorageV2")
    account_tier                      = optional(string, "Standard")
    account_replication_type          = optional(string, "LRS")
    access_tier                       = optional(string, "Hot")
    min_tls_version                   = optional(string, "TLS1_2")
    public_network_access_enabled     = optional(bool, false)
    shared_access_key_enabled         = optional(bool, true)
    allow_nested_items_to_be_public   = optional(bool, false)
    infrastructure_encryption_enabled = optional(bool, false)
    default_to_oauth_authentication   = optional(bool, true)

    create_private_dns_zones             = optional(bool, true)
    private_dns_zone_resource_group_name = optional(string)
    existing_private_dns_zone_ids        = optional(map(string), {})

    containers = optional(list(object({
      name                  = string
      container_access_type = optional(string, "private")
    })), [])

    queues = optional(list(object({
      name = string
    })), [])


    file_shares = optional(list(object({
      name             = string
      quota            = optional(number, 5)
      access_tier      = optional(string, "TransactionOptimized")
      enabled_protocol = optional(string, "SMB")
    })), [])


    tables = optional(list(object({
      name = string
    })), [])

    network_rules = optional(object({
      default_action             = string
      bypass                     = optional(list(string), ["AzureServices"])
      ip_rules                   = optional(list(string), [])
      virtual_network_subnet_ids = optional(list(string), [])
    }))

    identity = optional(object({
      type         = string
      identity_ids = optional(list(string), [])
    }))

    blob_properties = optional(object({
      versioning_enabled       = optional(bool, false)
      change_feed_enabled      = optional(bool, false)
      last_access_time_enabled = optional(bool, false)

      delete_retention_policy = optional(object({
        days = number
      }))

      container_delete_retention_policy = optional(object({
        days = number
      }))
    }))

    private_endpoints = optional(map(object({
      name                            = optional(string)
      subnet_name                     = string
      private_ip_address              = string
      subresource_name                = string
      private_dns_zone_names          = optional(list(string), [])
      private_dns_zone_resource_ids   = optional(list(string), [])
      private_service_connection_name = optional(string)
      private_dns_zone_group_name     = optional(string)
      ip_configuration_name           = optional(string)
      is_manual_connection            = optional(bool, false)
      request_message                 = optional(string)
      tags                            = optional(map(string), {})
    })), {})
  }))
}
