output "vms_web_private_ips" {
  description = "IPs privados das VMs web"
  value = {
    for vm_key, vm in module.vms_web :
    vm_key => vm.nic_private_ip
  }
}

output "vms_web_public_ips" {
  description = "IPs públicos das VMs Web"
  value = {
    for k, v in module.vms_web :
    k => v.public_ip_address
    if v.public_ip_address != null
  }
}
