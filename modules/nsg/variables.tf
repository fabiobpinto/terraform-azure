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
  description = "The ID of the subnet where the network security group will be deployed."
  type        = any
}

variable "nsg_rules" {
  type = list(object({
    name      = string
    priority  = number
    direction = string

    access   = optional(string, "Allow")
    protocol = optional(string, "Tcp")

    source_port_range      = optional(string, "*")
    destination_port_range = string

    source_address_prefix      = optional(string, "*")
    destination_address_prefix = optional(string, "*")
  }))
  description = "NSG rules by subnet type"
}