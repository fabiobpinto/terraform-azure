output "vms_web_private_ips" {
  description = "IPs privados das VMs web"
  value = {
    for vm_key, vm in module.vms_web :
    vm_key => vm.nic_private_ip
  }
}

output "loadbalancer_public_ips" {
  description = "IPs públicos dos Load Balancers públicos"
  value = {
    for lb_key, lb in module.loadbalancer_public :
    lb.lb_name => module.public_ip_loadbalancer[lb_key].public_ip_address
  }
}

output "vms_ansible_public_ips" {
  description = "IPs públicos das VMs Ansible"
  value = {
    for k, v in module.vms_ansible :
    k => v.public_ip_address
    if v.public_ip_address != null
  }
}

output "loadbalancers_private_ips" {
  description = "IPs privados dos Load Balancers internos"
  value = {
    for _, lb in module.loadbalancer_private :
    lb.lb_name => one(values(lb.private_ips))
  }
}