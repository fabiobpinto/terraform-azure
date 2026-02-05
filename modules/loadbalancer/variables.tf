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

variable "lb" {
  type = object({
    name     = string
    sku      = optional(string, "Standard")
    sku_tier = optional(string, "Regional")
    frontend_ip_configuration = map(object({
      name                          = optional(string)
      private_ip_address            = optional(string)
      private_ip_address_allocation = optional(string)
      public_ip_address_id          = optional(string)
      subnet_id                     = optional(string)
    }))
  })
  description = "Load Balancer configuration."
}

variable "lb_probes" {
  type = map(object({
    name                = optional(string)
    port                = number
    interval_in_seconds = number
    number_of_probes    = optional(number)
    probe_threshold     = optional(number)
    protocol            = string
    request_path        = optional(string)
  }))
  description = "Load Balancer probes configuration."
}

variable "lb_rules" {
  type = map(object({
    name                           = optional(string)
    protocol                       = string
    frontend_port                  = number
    backend_port                   = number
    frontend_ip_configuration_name = string

    idle_timeout_in_minutes  = optional(number)
    load_distribution        = optional(string)
    backend_address_pool_ids = optional(list(string))
    disable_outbound_snat    = optional(bool)
    probe_id                 = optional(string)
    probe_key                = string

  }))
  description = "Load Balancer rules configuration."
}

variable "nic_be_pool_associations" {
  type = map(object({
    network_interface_id  = string
    ip_configuration_name = string
  }))
  description = "Network Interface to Backend Address Pool associations."
}

variable "lb_nat_rules" {
  type = map(object({
    name                           = string
    protocol                       = string
    frontend_port                  = number
    backend_port                   = number
    frontend_ip_configuration_name = string
  }))
  default     = {}
  description = "Inbound NAT rules do Load Balancer"
}

variable "nic_nat_rule_associations" {
  type = map(object({
    network_interface_id  = string
    ip_configuration_name = string
    nat_rule_key          = string
  }))
  default     = {}
  description = "Associação de NAT Rules com NICs"
}