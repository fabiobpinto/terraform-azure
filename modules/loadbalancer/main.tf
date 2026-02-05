resource "azurerm_lb" "lb" {
  name                = var.lb_name
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = var.sku
  tags                = var.tags

  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = var.public_ip_address_id
  }
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "backend-pool"
}

resource "azurerm_lb_probe" "health_probe" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "http-health-probe"
  protocol        = "Http"
  port            = 80
  request_path    = "/"
}

resource "azurerm_lb_rule" "lb_rule_http" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = var.frontend_ip_configuration_name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_pool.id]
  probe_id                       = azurerm_lb_probe.health_probe.id
}
