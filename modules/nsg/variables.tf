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

variable "nsg_name" {
  description = "Network Security Group name"
  type        = string
}

variable "nsg_subnet_id" {
  description = "Network Security Group number"
  type        = any
}

variable "nsg_rules" {
  description = "List of NSG rules"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
}