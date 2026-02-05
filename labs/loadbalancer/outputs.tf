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

output "loadbalancer_public_ips" {
  description = "IPs públicos dos Load Balancers"
  value = {
    for lb_key, pip in module.public_ip_loadbalancer :
    lb_key => pip.public_ip_address
  }
}

output "loadbalancer_ids" {
  description = "IDs dos Load Balancers"
  value = {
    for lb_key, lb in module.loadbalancer :
    lb_key => lb.lb_id
  }
}
