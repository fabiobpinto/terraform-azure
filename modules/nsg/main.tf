resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "rules" {
  for_each = { for rule in var.nsg_rules : rule.name => rule }

  name      = each.value.name
  priority  = each.value.priority
  direction = each.value.direction
  access    = each.value.access
  protocol  = each.value.protocol

  source_port_range      = each.value.source_port_range
  destination_port_range = each.value.destination_port_range
  source_address_prefix = length(concat(
    each.value.source_application_security_group_ids,
    [for asg_key in each.value.source_application_security_group_keys : var.application_security_group_ids[asg_key]]
  )) == 0 ? each.value.source_address_prefix : null
  destination_address_prefix = length(concat(
    each.value.destination_application_security_group_ids,
    [for asg_key in each.value.destination_application_security_group_keys : var.application_security_group_ids[asg_key]]
  )) == 0 ? each.value.destination_address_prefix : null

  source_application_security_group_ids = length(concat(
    each.value.source_application_security_group_ids,
    [for asg_key in each.value.source_application_security_group_keys : var.application_security_group_ids[asg_key]]
    )) == 0 ? null : concat(
    each.value.source_application_security_group_ids,
    [for asg_key in each.value.source_application_security_group_keys : var.application_security_group_ids[asg_key]]
  )
  destination_application_security_group_ids = length(concat(
    each.value.destination_application_security_group_ids,
    [for asg_key in each.value.destination_application_security_group_keys : var.application_security_group_ids[asg_key]]
    )) == 0 ? null : concat(
    each.value.destination_application_security_group_ids,
    [for asg_key in each.value.destination_application_security_group_keys : var.application_security_group_ids[asg_key]]
  )

  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_subnet_network_security_group_association" "assoc" {
  subnet_id                 = var.nsg_subnet_id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
