locals {
  default_tags = {
    managed_by = "terraform"
  }

  tags = merge(local.default_tags, var.tags)

  storage_private_dns_zones = {
    blob  = "privatelink.blob.core.windows.net"
    file  = "privatelink.file.core.windows.net"
    queue = "privatelink.queue.core.windows.net"
    table = "privatelink.table.core.windows.net"
    web   = "privatelink.web.core.windows.net"
    dfs   = "privatelink.dfs.core.windows.net"
  }

  private_dns_zone_keys = toset(flatten([
    for pe_key, pe_value in var.private_endpoints :
    pe_value.private_dns_zone_names
  ]))

  created_private_dns_zone_ids = {
    for key, zone in azurerm_private_dns_zone.this :
    key => zone.id
  }

  private_dns_zone_ids = merge(
    var.existing_private_dns_zone_ids,
    local.created_private_dns_zone_ids
  )
}

resource "azurerm_storage_account" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  account_kind             = var.account_kind
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  access_tier              = var.access_tier

  min_tls_version                   = var.min_tls_version
  https_traffic_only_enabled        = var.https_traffic_only_enabled
  public_network_access_enabled     = var.public_network_access_enabled
  shared_access_key_enabled         = var.shared_access_key_enabled
  allow_nested_items_to_be_public   = var.allow_nested_items_to_be_public
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  default_to_oauth_authentication   = var.default_to_oauth_authentication
  is_hns_enabled                    = var.is_hns_enabled
  nfsv3_enabled                     = var.nfsv3_enabled
  sftp_enabled                      = var.sftp_enabled
  large_file_share_enabled          = var.large_file_share_enabled
  local_user_enabled                = var.local_user_enabled

  dynamic "identity" {
    for_each = var.identity == null ? [] : [var.identity]

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "blob_properties" {
    for_each = var.blob_properties == null ? [] : [var.blob_properties]

    content {
      versioning_enabled       = blob_properties.value.versioning_enabled
      change_feed_enabled      = blob_properties.value.change_feed_enabled
      last_access_time_enabled = blob_properties.value.last_access_time_enabled

      dynamic "delete_retention_policy" {
        for_each = blob_properties.value.delete_retention_policy == null ? [] : [blob_properties.value.delete_retention_policy]

        content {
          days = delete_retention_policy.value.days
        }
      }

      dynamic "container_delete_retention_policy" {
        for_each = blob_properties.value.container_delete_retention_policy == null ? [] : [blob_properties.value.container_delete_retention_policy]

        content {
          days = container_delete_retention_policy.value.days
        }
      }
    }
  }

  dynamic "network_rules" {
    for_each = var.network_rules == null ? [] : [var.network_rules]

    content {
      default_action             = network_rules.value.default_action
      bypass                     = network_rules.value.bypass
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = network_rules.value.virtual_network_subnet_ids
    }
  }

  tags = local.tags

  lifecycle {
    precondition {
      condition = (
        var.allow_public_only ||
        length(var.private_endpoints) > 0 ||
        var.public_network_access_enabled == false
      )

      error_message = "Storage Account com public_network_access_enabled=true e sem Private Endpoint. Informe allow_public_only=true com justificativa ou configure private_endpoints."
    }

    precondition {
      condition = (
        var.shared_access_key_enabled ||
        length(var.queues) == 0 && length(var.tables) == 0
      )

      error_message = "Queues e Tables exigem shared_access_key_enabled=true, pois os recursos azurerm_storage_queue/table usam shared key."
    }
  }
}

resource "azurerm_storage_container" "this" {
  for_each = {
    for container in var.containers :
    container.name => container
  }

  name                  = each.value.name
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = each.value.container_access_type
}


resource "azurerm_storage_share" "this" {
  for_each = {
    for share in var.file_shares :
    share.name => share
  }

  name               = each.value.name
  storage_account_id = azurerm_storage_account.this.id
  quota              = each.value.quota
  access_tier        = each.value.access_tier
  enabled_protocol   = each.value.enabled_protocol
}


resource "azurerm_storage_queue" "this" {
  for_each = {
    for queue in var.queues :
    queue.name => queue
  }

  name               = each.value.name
  storage_account_id = azurerm_storage_account.this.id
}

resource "azurerm_storage_table" "this" {
  for_each = {
    for table in var.tables :
    table.name => table
  }

  name                 = each.value.name
  storage_account_name = azurerm_storage_account.this.name
}

resource "azurerm_private_dns_zone" "this" {
  for_each = var.create_private_dns_zones ? local.private_dns_zone_keys : toset([])

  name                = local.storage_private_dns_zones[each.key]
  resource_group_name = var.private_dns_zone_resource_group_name != null ? var.private_dns_zone_resource_group_name : var.resource_group_name

  tags = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = var.create_private_dns_zones && var.virtual_network_id != null ? local.private_dns_zone_keys : toset([])

  name                  = "vnetlink-${var.name}-${each.key}"
  resource_group_name   = var.private_dns_zone_resource_group_name != null ? var.private_dns_zone_resource_group_name : var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this[each.key].name
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = false

  tags = local.tags
}

resource "azurerm_private_endpoint" "this" {
  for_each = var.private_endpoints

  name                = coalesce(each.value.name, "pep-${var.name}-${each.key}")
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_ids[each.value.subnet_name]

  tags = merge(local.tags, each.value.tags)

  private_service_connection {
    name                           = coalesce(each.value.private_service_connection_name, "psc-${var.name}-${each.key}")
    private_connection_resource_id = azurerm_storage_account.this.id
    subresource_names              = [each.value.subresource_name]
    is_manual_connection           = each.value.is_manual_connection
    request_message                = each.value.is_manual_connection ? each.value.request_message : null
  }

  ip_configuration {
    name               = coalesce(each.value.ip_configuration_name, "ipconfig-${var.name}-${each.key}")
    private_ip_address = each.value.private_ip_address
    subresource_name   = each.value.subresource_name
    member_name        = each.value.subresource_name
  }

  dynamic "private_dns_zone_group" {
    for_each = length(concat(each.value.private_dns_zone_names, each.value.private_dns_zone_resource_ids)) > 0 ? [1] : []

    content {
      name = coalesce(each.value.private_dns_zone_group_name, "pdzg-${var.name}-${each.key}")

      private_dns_zone_ids = concat(
        [
          for dns_zone_name in each.value.private_dns_zone_names :
          local.private_dns_zone_ids[dns_zone_name]
        ],
        each.value.private_dns_zone_resource_ids
      )
    }
  }

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.this
  ]
}
