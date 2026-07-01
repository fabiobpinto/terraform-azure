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

variable "vhub_name" {
  description = "Virtual Hub name"
  type        = string
}

variable "virtual_wan_id" {
  description = "Virtual WAN ID to which the Virtual Hub will be associated"
  type        = string
}

variable "address_prefix" {
  description = "Address prefix for the Virtual Hub"
  type        = string
}
