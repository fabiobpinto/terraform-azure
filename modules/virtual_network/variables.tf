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

###############################################################
# Virtual Network
###############################################################
variable "vnet_name" {
  type        = string
  description = "The Vnet name"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "The address space for the virtual network."
}

###############################################################
# Subnets
###############################################################
variable "subnets" {
  description = "Subnet configuration."
  type = map(object({
    name             = string
    address_prefixes = list(string)
    nsg_name         = optional(string)
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = list(string)
      })
    }))
  }))
}
