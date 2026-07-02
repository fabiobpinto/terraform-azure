output "nic_private_ip" {
  value       = azurerm_network_interface.nic_windows.private_ip_address
  description = "Private IP address of the network interface"
}

output "nic_id" {
  value       = azurerm_network_interface.nic_windows.id
  description = "ID of the network interface"
}

output "nic_ip_configuration_name" {
  value       = azurerm_network_interface.nic_windows.ip_configuration[0].name
  description = "Name of the NIC IP configuration"
}

output "vm_name" {
  value       = azurerm_windows_virtual_machine.vm_windows.name
  description = "Name of the Windows virtual machine"
}

output "public_ip_address" {
  value       = var.enable_public_ip ? azurerm_public_ip.pip[0].ip_address : null
  description = "Public IP address of the VM (if exists)"
}

output "public_ip_id" {
  value       = var.enable_public_ip ? azurerm_public_ip.pip[0].id : null
  description = "ID of the Public IP of the VM (if exists)"
}

output "vm_id" {
  description = "ID of the Windows Virtual Machine"
  value       = azurerm_windows_virtual_machine.vm_windows.id
}
