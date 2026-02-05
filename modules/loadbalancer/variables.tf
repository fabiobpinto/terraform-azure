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

variable "lb_name" {
  type        = string
  description = "The name of the load balancer."
}

variable "frontend_ip_configuration_name" {
  type        = string
  description = "The name of the frontend IP configuration."
}

variable "public_ip_address_id" {
  type        = string
  description = "The ID of the public IP address for the load balancer."
}

variable "sku" {
  type        = string
  description = "The SKU of the load balancer. Accepted values are Basic and Standard."
  default     = "Standard"
}