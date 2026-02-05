output "lb_id" {
  description = "The ID of the load balancer."
  value       = azurerm_lb.lb.id
}

output "backend_pool_id" {
  description = "The ID of the backend address pool."
  value       = azurerm_lb_backend_address_pool.backend_pool.id
}

output "frontend_ip_configuration" {
  description = "The frontend IP configuration of the load balancer."
  value       = azurerm_lb.lb.frontend_ip_configuration
}
