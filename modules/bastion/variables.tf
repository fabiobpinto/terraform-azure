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

variable "bastion_name" {
  type        = string
  description = "The name of the bastion host."
}

variable "bastion_subnet_id" {
  description = "The ID of the subnet where the bastion host will be deployed."
  type        = any
}

variable "public_ip_address_id" {
  description = "The ID of the public IP address associated with the bastion host."
  type        = any
}

variable "bastion" {
  description = "Configuration object for the bastion host."
  type = object({
    copy_paste_enabled        = optional(bool, true)
    file_copy_enabled         = optional(bool, false)
    ip_connect_enabled        = optional(bool, false)
    kerberos_enabled          = optional(bool, false)
    scale_units               = optional(number, 2)
    session_recording_enabled = optional(bool, false)
    shareable_link_enabled    = optional(bool, false)
    sku                       = optional(string, "Standard")
    tunneling_enabled         = optional(bool, false)
    virtual_network_id        = optional(string, null)
    zones                     = optional(list(string), [])
  })
}