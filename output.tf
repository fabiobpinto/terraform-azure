output "rg-name" {
  value = module.rg.rg_name
}

output "vms_web_private_ips" {
  description = "IPs privados das VMs web"
  value = {
    for vm_key, vm in module.vms_web :
    vm_key => vm.nic_private_ip
  }
}

output "vms_app_private_ips" {
  description = "IPs privados das VMs app"
  value = {
    for vm_key, vm in module.vms_app :
    vm_key => vm.nic_private_ip
  }
}

output "vms_app_public_ips" {
  description = "IPs públicos das VMs app"
  value = {
    for vm_key, pip in module.public_ip_app :
    vm_key => pip.public_ip_address
  }
}

output "vms_web_public_ips" {
  description = "IPs públicos das VMs web"
  value = {
    for vm_key, pip in module.public_ip_web :
    vm_key => pip.public_ip_address
  }
}

output "bastion_public_ips" {
  description = "IPs públicos do bastion"
  value = {
    for vm_key, pip in module.public_ip_bastion :
    vm_key => pip.public_ip_address
  }
}