variable "name" {
  description = "Nome do Storage Account. Deve ser globalmente único, apenas letras minúsculas e números, entre 3 e 24 caracteres."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "O nome do Storage Account deve conter apenas letras minúsculas e números, com tamanho entre 3 e 24 caracteres."
  }
}

variable "resource_group_name" {
  description = "Nome do Resource Group onde o Storage Account será criado."
  type        = string
}

variable "location" {
  description = "Região Azure."
  type        = string
}

variable "tags" {
  description = "Tags aplicadas aos recursos."
  type        = map(string)
  default     = {}
}

variable "account_kind" {
  description = "Tipo do Storage Account."
  type        = string
  default     = "StorageV2"
}

variable "account_tier" {
  description = "Tier do Storage Account."
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Tipo de replicação."
  type        = string
  default     = "LRS"
}

variable "access_tier" {
  description = "Access tier do Storage Account."
  type        = string
  default     = "Hot"
}

variable "min_tls_version" {
  description = "Versão mínima do TLS."
  type        = string
  default     = "TLS1_2"
}

variable "https_traffic_only_enabled" {
  description = "Força tráfego HTTPS."
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Habilita ou desabilita acesso público ao Storage Account."
  type        = bool
  default     = false
}

variable "shared_access_key_enabled" {
  description = "Habilita shared key no Storage Account."
  type        = bool
  default     = true
}

variable "allow_nested_items_to_be_public" {
  description = "Permite que itens internos sejam públicos."
  type        = bool
  default     = false
}

variable "infrastructure_encryption_enabled" {
  description = "Habilita encryption at infrastructure level."
  type        = bool
  default     = false
}

variable "default_to_oauth_authentication" {
  description = "Define OAuth como autenticação padrão."
  type        = bool
  default     = true
}

variable "is_hns_enabled" {
  description = "Habilita Hierarchical Namespace, usado em ADLS Gen2."
  type        = bool
  default     = false
}

variable "nfsv3_enabled" {
  description = "Habilita NFSv3."
  type        = bool
  default     = false
}

variable "sftp_enabled" {
  description = "Habilita SFTP."
  type        = bool
  default     = false
}

variable "large_file_share_enabled" {
  description = "Habilita large file share."
  type        = bool
  default     = false
}

variable "local_user_enabled" {
  description = "Habilita local users no Storage Account."
  type        = bool
  default     = false
}

variable "allow_public_only" {
  description = "Permite criar Storage público sem Private Endpoint. Use somente com justificativa."
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "Mapa de nomes de subnets para IDs. Exemplo: module.network.subnet_ids."
  type        = map(string)
  default     = {}
}

variable "virtual_network_id" {
  description = "ID da VNet usada para link com Private DNS Zone."
  type        = string
  default     = null
}

variable "create_private_dns_zones" {
  description = "Define se o módulo deve criar as Private DNS Zones."
  type        = bool
  default     = true
}

variable "private_dns_zone_resource_group_name" {
  description = "Resource Group das Private DNS Zones. Se null, usa o mesmo Resource Group do Storage."
  type        = string
  default     = null
}

variable "existing_private_dns_zone_ids" {
  description = "Mapa de Private DNS Zones já existentes. Exemplo: { blob = '/subscriptions/.../privatelink.blob.core.windows.net' }."
  type        = map(string)
  default     = {}
}

variable "containers" {
  description = "Containers Blob a serem criados."
  type = list(object({
    name                  = string
    container_access_type = optional(string, "private")
  }))
  default = []
}

variable "queues" {
  description = "Queues a serem criadas."
  type = list(object({
    name = string
  }))
  default = []
}

variable "tables" {
  description = "Tables a serem criadas."
  type = list(object({
    name = string
  }))
  default = []
}

variable "network_rules" {
  description = "Network rules opcionais do Storage Account."
  type = object({
    default_action             = string
    bypass                     = optional(list(string), ["AzureServices"])
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = null
}

variable "identity" {
  description = "Identity opcional do Storage Account."
  type = object({
    type         = string
    identity_ids = optional(list(string), [])
  })
  default = null
}

variable "blob_properties" {
  description = "Configurações opcionais de Blob."
  type = object({
    versioning_enabled       = optional(bool, false)
    change_feed_enabled      = optional(bool, false)
    last_access_time_enabled = optional(bool, false)

    delete_retention_policy = optional(object({
      days = number
    }), null)

    container_delete_retention_policy = optional(object({
      days = number
    }), null)
  })
  default = null
}


variable "file_shares" {
  description = "Azure File Shares a serem criados dentro do Storage Account."
  type = list(object({
    name             = string
    quota            = optional(number, 5)
    access_tier      = optional(string, "TransactionOptimized")
    enabled_protocol = optional(string, "SMB")
  }))
  default = []
}


variable "private_endpoints" {
  description = "Mapa de Private Endpoints. A subnet é informada pelo nome e resolvida via var.subnet_ids."
  type = map(object({
    name                            = optional(string)
    subnet_name                     = string
    private_ip_address              = string
    subresource_name                = string
    private_dns_zone_names          = optional(list(string), [])
    private_dns_zone_resource_ids   = optional(list(string), [])
    private_service_connection_name = optional(string)
    private_dns_zone_group_name     = optional(string)
    ip_configuration_name           = optional(string)
    is_manual_connection            = optional(bool, false)
    request_message                 = optional(string)
    tags                            = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for pe_key, pe_value in var.private_endpoints :
      contains(["blob", "file", "queue", "table", "web", "dfs"], pe_value.subresource_name)
    ])

    error_message = "subresource_name deve ser um dos seguintes valores: blob, file, queue, table, web ou dfs."
  }

  validation {
    condition = alltrue([
      for pe_key, pe_value in var.private_endpoints :
      length(trim(pe_value.private_ip_address, " ")) > 0
    ])

    error_message = "private_ip_address é obrigatório para cada Private Endpoint."
  }
}
