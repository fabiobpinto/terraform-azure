resource "time_static" "created" {}

locals {
  default_tags = {
    created_by = "Terraform"
    # Horário de Brasília (UTC-3, fixo desde 2019).
    created_date = formatdate("YYYY/MM/DD - hh:mm:ss", timeadd(time_static.created.rfc3339, "-3h"))
  }
  tags = merge(var.tags, local.default_tags)
}

data "azurerm_client_config" "current" {}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault
resource "azurerm_key_vault" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.sku_name

  soft_delete_retention_days    = var.soft_delete_retention_days
  purge_protection_enabled      = var.purge_protection_enabled
  rbac_authorization_enabled    = var.enable_rbac_authorization
  public_network_access_enabled = var.public_network_access_enabled

  dynamic "network_acls" {
    for_each = var.network_acls == null ? [] : [var.network_acls]
    content {
      default_action             = network_acls.value.default_action
      bypass                     = network_acls.value.bypass
      ip_rules                   = network_acls.value.ip_rules
      virtual_network_subnet_ids = network_acls.value.virtual_network_subnet_ids
    }
  }

  tags = local.tags

  lifecycle {
    precondition {
      condition     = var.allow_public_only || length(var.private_endpoints) > 0 || !var.public_network_access_enabled
      error_message = "Key Vault has public_network_access_enabled=true and no private_endpoints. Set allow_public_only=true (with justification) or configure private_endpoints."
    }
    precondition {
      condition     = !var.enable_rbac_authorization || length(var.access_policies) == 0
      error_message = "access_policies must be empty when enable_rbac_authorization = true. Use Azure RBAC role assignments instead."
    }
  }
}

resource "azurerm_role_assignment" "terraform_secrets_officer" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# When enable_rbac_authorization = true, access_policies are not supported.
# A precondition on the parent vault rejects the combination at plan time;
# this resource also short-circuits to {} so callers can leave stale entries
# in their tfvars while RBAC is on without forcing a destroy.
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy
resource "azurerm_key_vault_access_policy" "this" {
  for_each = var.enable_rbac_authorization ? {} : { for p in var.access_policies : p.object_id => p }

  key_vault_id            = azurerm_key_vault.this.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = each.value.object_id
  application_id          = each.value.application_id
  key_permissions         = each.value.key_permissions
  secret_permissions      = each.value.secret_permissions
  certificate_permissions = each.value.certificate_permissions
  storage_permissions     = each.value.storage_permissions
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret
resource "azurerm_key_vault_secret" "this" {
  # var.secrets is sensitive; for_each keys must be non-sensitive. We extract
  # only the names (not the values) and look up the rest by key.
  for_each = nonsensitive(toset([for s in var.secrets : s.name]))

  name         = each.key
  value        = one([for s in var.secrets : s.value if s.name == each.key])
  content_type = one([for s in var.secrets : s.content_type if s.name == each.key])
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [
    azurerm_private_endpoint.this
  ]

}

# Private Endpoints. Pass an entry in `private_endpoints` map to create one per key.
# Key Vault only accepts subresource `vault`.
# https://learn.microsoft.com/azure/key-vault/general/private-link-service
resource "azurerm_private_endpoint" "this" {
  for_each = var.private_endpoints

  name                = coalesce(each.value.name, "pep-${var.name}-${each.key}")
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = each.value.subnet_resource_id
  tags                = merge(each.value.tags, local.default_tags)

  private_service_connection {
    name                           = coalesce(each.value.private_service_connection_name, "psc-${var.name}-${each.key}")
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = each.value.subresource_names
    is_manual_connection           = each.value.is_manual_connection
    request_message                = each.value.is_manual_connection ? each.value.request_message : null
  }

  dynamic "ip_configuration" {
    for_each = try(each.value.private_ip_address, null) == null ? [] : [1]

    content {
      name               = "ipconfig"
      private_ip_address = each.value.private_ip_address
      subresource_name   = "vault"
      member_name        = "default"
    }
  }

  dynamic "private_dns_zone_group" {
    for_each = length(each.value.private_dns_zone_resource_ids) > 0 ? [1] : []
    content {
      name                 = var.private_dns_zone_group_name
      private_dns_zone_ids = each.value.private_dns_zone_resource_ids
    }
  }
}

# ASG associations for private endpoint NICs (one per (PE,ASG) pair).
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint_application_security_group_association
locals {
  pe_asg_associations = merge([
    for k, v in var.private_endpoints : {
      for asg_id in v.application_security_group_ids :
      "${k}|${asg_id}" => { pe_key = k, asg_id = asg_id }
    }
  ]...)
}

resource "azurerm_private_endpoint_application_security_group_association" "this" {
  for_each = local.pe_asg_associations

  private_endpoint_id           = azurerm_private_endpoint.this[each.value.pe_key].id
  application_security_group_id = each.value.asg_id
}
