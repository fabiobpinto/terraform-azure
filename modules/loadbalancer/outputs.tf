output "resource_id" {
  description = "The resource Id of the resource"
  value       = azurerm_lb.lb.id
}

output "lb_name" {
  description = "Name of the Load Balancer"
  value       = azurerm_lb.lb.name
}

output "private_ips" {
  description = "Private IPs of the Load Balancer frontends"
  value = {
    for fe in azurerm_lb.lb.frontend_ip_configuration :
    fe.name => fe.private_ip_address
  }
}

output "lb_id" {
  description = "ID of the Load Balancer"
  value       = azurerm_lb.lb.id
}