# output "vms_web_private_ips" {
#   description = "IPs privados das VMs web"
#   value = {
#     for vm_key, vm in module.vms_web :
#     vm_key => vm.nic_private_ip
#   }
# }

# output "vms_app_private_ips" {
#   description = "IPs privados das VMs app"
#   value = {
#     for vm_key, vm in module.vms_app :
#     vm_key => vm.nic_private_ip
#   }
# }

# output "vms_app_public_ips" {
#   description = "IPs públicos das VMs Ansible"
#   value = {
#     for k, v in module.vms_app :
#     k => v.public_ip_address
#     if v.public_ip_address != null
#   }
# }

# output "vms_web_public_ips" {
#   description = "IPs públicos das VMs Web"
#   value = {
#     for k, v in module.vms_web :
#     k => v.public_ip_address
#     if v.public_ip_address != null
#   }
# }

# output "bastion_public_ips" {
#   description = "IPs públicos do bastion"
#   value = {
#     for vm_key, pip in module.public_ip_bastion :
#     vm_key => pip.public_ip_address
#   }
# }

output "loadbalancer_public_ips" {
  description = "IPs públicos dos Load Balancers públicos"
  value = {
    for lb_key, lb in module.loadbalancer_public :
    lb.lb_name => module.public_ip_loadbalancer[lb_key].public_ip_address
  }
}
