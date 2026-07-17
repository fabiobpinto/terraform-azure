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

variable "environment" {
  type        = string
  description = "The environment for the deployment (e.g., dev, prd)."
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource group."
}
