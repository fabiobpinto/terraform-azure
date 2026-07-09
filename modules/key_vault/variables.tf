variable "name" {
  description = "Key Vault name (3-24 alphanumeric + hyphen, globally unique)."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{1,22}[a-zA-Z0-9]$", var.name))
    error_message = "Key Vault name must be 3-24 chars, start with a letter, end with a letter or digit, and contain only letters, digits and hyphens."
  }
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "sku_name" {
  description = "Key Vault SKU (standard or premium)."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "sku_name must be standard or premium."
  }
}

variable "soft_delete_retention_days" {
  description = "Soft-delete retention (7-90)."
  type        = number
  default     = 90
}

variable "purge_protection_enabled" {
  description = "Enable purge protection."
  type        = bool
  default     = true
}

variable "enable_rbac_authorization" {
  description = "Use Azure RBAC instead of access policies."
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Allow public network access."
  type        = bool
  default     = false
}

variable "network_acls" {
  description = "Network ACLs. Set null to skip."
  type = object({
    default_action             = string
    bypass                     = optional(string, "AzureServices")
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = null
}

variable "access_policies" {
  description = "Access policies (used only when enable_rbac_authorization = false)."
  type = list(object({
    object_id               = string
    application_id          = optional(string)
    key_permissions         = optional(list(string), [])
    secret_permissions      = optional(list(string), [])
    certificate_permissions = optional(list(string), [])
    storage_permissions     = optional(list(string), [])
  }))
  default = []
}

variable "secrets" {
  description = "Secrets to create. Mark the whole list sensitive so values never appear in plan output or CI logs."
  type = list(object({
    name         = string
    value        = string
    content_type = optional(string)
  }))
  default   = []
  sensitive = true
}

variable "tags" {
  description = "Tags applied to the Key Vault."
  type        = map(string)
  default     = {}
}

variable "private_endpoints" {
  description = <<-EOT
    Map of private endpoints to create. Default `{}` (none).
    Each entry creates one azurerm_private_endpoint linked to this Key Vault.
    Key Vault only accepts subresource `vault`.
    Example:
      private_endpoints = {
        vault = {
          subnet_resource_id            = "/subscriptions/.../subnets/snet-pe"
          private_dns_zone_resource_ids = ["/subscriptions/.../privateDnsZones/privatelink.vaultcore.azure.net"]
        }
      }
  EOT
  type = map(object({
    subnet_resource_id              = string
    private_ip_address              = optional(string)
    private_dns_zone_resource_ids   = optional(list(string), [])
    name                            = optional(string)
    private_service_connection_name = optional(string)
    subresource_names               = optional(list(string), ["vault"])
    is_manual_connection            = optional(bool, false)
    request_message                 = optional(string)
    application_security_group_ids  = optional(list(string), [])
    tags                            = optional(map(string), {})
  }))
  default = {}

  validation {
    condition     = alltrue([for k, v in var.private_endpoints : try(length(v.subnet_resource_id) > 0, false)])
    error_message = "private_endpoints[*].subnet_resource_id is required and must be non-empty."
  }
  validation {
    condition     = alltrue([for k, v in var.private_endpoints : alltrue([for s in v.subresource_names : s == "vault"])])
    error_message = "Key Vault private endpoints only accept subresource_names = [\"vault\"]."
  }
}

variable "allow_public_only" {
  description = "When false (default), the plan fails if no private_endpoints are configured AND public_network_access_enabled = true. Set to true only with explicit justification."
  type        = bool
  default     = false
}

variable "private_dns_zone_group_name" {
  description = "Name of the private_dns_zone_group inside each private endpoint. Default 'default'. Override only if your tooling expects a specific name."
  type        = string
  default     = "default"
}
