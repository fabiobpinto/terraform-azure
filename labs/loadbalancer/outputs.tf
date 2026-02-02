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