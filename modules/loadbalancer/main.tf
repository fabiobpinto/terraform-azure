resource "azurerm_lb" "lb" {
  name                = var.lb.name
  resource_group_name = var.rg_name
  location            = var.location
  sku                 = var.lb.sku
  sku_tier            = var.lb.sku_tier
  tags                = var.tags

  dynamic "frontend_ip_configuration" {
    for_each = var.lb.frontend_ip_configuration

    content {
      name                          = frontend_ip_configuration.value.name
      private_ip_address            = frontend_ip_configuration.value.private_ip_address
      private_ip_address_allocation = frontend_ip_configuration.value.private_ip_address_allocation
      public_ip_address_id          = frontend_ip_configuration.value.public_ip_address_id
      subnet_id                     = frontend_ip_configuration.value.subnet_id
    }
  }
}

resource "azurerm_lb_backend_address_pool" "be_address_pool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "backend_address_pool-${var.lb.name}"
}

resource "azurerm_lb_probe" "lb_probe" {
  for_each = var.lb_probes

  loadbalancer_id     = azurerm_lb.lb.id
  name                = "probe-${each.value.name}"
  port                = each.value.port
  interval_in_seconds = each.value.interval_in_seconds
  number_of_probes    = each.value.number_of_probes
  probe_threshold     = each.value.probe_threshold
  protocol            = each.value.protocol
  request_path        = (each.value.protocol == "Http" || each.value.protocol == "Https") ? each.value.request_path : null
}

resource "azurerm_lb_rule" "lb_rule" {
  for_each = var.lb_rules

  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "rule-${each.value.name}"
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  backend_address_pool_ids       = azurerm_lb_backend_address_pool.be_address_pool.*.id
  disable_outbound_snat          = each.value.disable_outbound_snat
  idle_timeout_in_minutes        = each.value.idle_timeout_in_minutes
  load_distribution              = each.value.load_distribution
  probe_id                       = azurerm_lb_probe.lb_probe[each.value.probe_key].id
}

resource "azurerm_network_interface_backend_address_pool_association" "nic_be_pool_association" {
  for_each = var.nic_be_pool_associations

  network_interface_id    = each.value.network_interface_id
  ip_configuration_name   = each.value.ip_configuration_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.be_address_pool.id
}

resource "azurerm_lb_nat_rule" "lb_nat_rule" {
  for_each = var.lb_nat_rules

  resource_group_name            = var.rg_name
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "nat-rule-${each.value.name}"
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name

}

resource "azurerm_network_interface_nat_rule_association" "nic_nat_rule_association" {
  for_each = var.nic_nat_rule_associations

  network_interface_id  = each.value.network_interface_id
  ip_configuration_name = each.value.ip_configuration_name
  nat_rule_id           = azurerm_lb_nat_rule.lb_nat_rule[each.value.nat_rule_key].id
}