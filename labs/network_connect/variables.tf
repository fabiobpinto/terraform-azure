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
  description = "Subnets configuration"
  type = map(object({
    name             = string
    address_prefixes = list(string)
    rule             = string
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string))
      })
    }))
  }))
}

variable "wan_name" {
  type = string
}

variable "vhub_name" {
  type = string
}

# variable "virtual_hub_connections" {
#   description = "Virtual Hub Connections."

#   type = map(object({
#     remote_virtual_network = string
#   }))
# }

variable "hub_address_prefix" {
  type = string
}


variable "route_table_name" {
  description = "The name of the Virtual Hub Route Table."
  type        = string
}

variable "route_table_labels" {
  description = "Labels assigned to the Virtual Hub Route Table."
  type        = list(string)
  default     = []
}

variable "routes" {
  description = "List of routes for the Virtual Hub Route Table."
  type = list(object({
    name              = string
    destinations_type = string
    destinations      = list(string)
    next_hop_type     = string
    next_hop          = optional(string)
  }))
  default = []
}
