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



variable "key_vaults" {
  description = "Key Vaults to create."
  type = map(object({
    name                          = string
    public_network_access_enabled = optional(bool, false)
    allow_public_only             = optional(bool, false)
    tags                          = optional(map(string), {})
    secrets = optional(list(object({
      name         = string
      value        = string
      content_type = optional(string)
    })), [])
    network_acls = optional(object({
      default_action             = string
      bypass                     = optional(string, "AzureServices")
      ip_rules                   = optional(list(string), [])
      virtual_network_subnet_ids = optional(list(string), [])
    }))
    private_endpoints = optional(map(object({
      name                           = string
      subnet_name                    = string
      private_ip_address             = optional(string)
      private_dns_zone_resource_ids  = optional(list(string), [])
      application_security_group_ids = optional(list(string), [])
      tags                           = optional(map(string), {})
    })), {})
  }))
}
