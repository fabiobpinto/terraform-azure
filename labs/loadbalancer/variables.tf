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
  sensitive = true
  description = "The admin password for the Linux virtual machine."
}

variable "vms_linux_ansible" {
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
  }))
  description = "Configuration object for the Linux virtual machine."
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
  }))
  description = "Configuration object for the Linux virtual machine."
}

variable "loadbalancer_private" {
  type = map(object({
    name     = string
    sku      = optional(string, "Standard")
    sku_tier = optional(string, "Regional")

    frontend_ip_configuration = map(object({
      name                          = string
      private_ip_address            = optional(string)
      private_ip_address_allocation = optional(string)
      public_ip_address_id          = optional(string)
      subnet_id                     = optional(string)
    }))
    lb_probes = map(object({
      name                = optional(string)
      port                = number
      protocol            = string
      interval_in_seconds = number
      number_of_probes    = optional(number)
      probe_threshold     = optional(number)
      request_path        = optional(string)
    }))
    lb_rules = map(object({
      name                           = optional(string)
      protocol                       = string
      frontend_port                  = number
      backend_port                   = number
      frontend_ip_configuration_name = optional(string)
      probe_key                      = string

      disable_outbound_snat   = optional(bool, true)
      idle_timeout_in_minutes = optional(number)
      load_distribution       = optional(string)
    }))
  }))
  description = "Load Balancer configuration."
}

variable "loadbalancer_public" {
  type = map(object({
    name     = string
    sku      = optional(string, "Standard")
    sku_tier = optional(string, "Regional")

    frontend_ip_configuration = map(object({
      name                 = optional(string)
      public_ip_address_id = optional(string)
    }))

    lb_probes = map(object({
      name                = optional(string)
      port                = number
      protocol            = string
      interval_in_seconds = number
      number_of_probes    = optional(number)
      probe_threshold     = optional(number)
      request_path        = optional(string)
    }))

    lb_rules = map(object({
      name                           = optional(string)
      protocol                       = string
      frontend_port                  = number
      backend_port                   = number
      frontend_ip_configuration_name = optional(string)
      probe_key                      = string
      # disable_outbound_snat          = optional(bool, true)
      disable_outbound_snat   = optional(bool)
      idle_timeout_in_minutes = optional(number)
      load_distribution       = optional(string)
    }))

    lb_nat_rules = optional(map(object({
      name          = string
      protocol      = string
      frontend_port = number
      backend_port  = number
      target_vm     = string
    })))

    nic_be_pool_associations = optional(map(any))
  }))
  description = "Load Balancer configuration."
}
