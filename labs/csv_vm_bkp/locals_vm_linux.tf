locals {
  vm_linux_csv = csvdecode(file("${path.module}/data/04-vms_linux.csv"))
  vms_linux = {
    for vm in local.vm_linux_csv :
    vm.name => {
      admin_username                  = vm.admin_username
      disable_password_authentication = lower(vm.disable_password_authentication) == "true"
      name                            = vm.name
      computer_name                   = vm.computer_name
      size                            = vm.size
      enable_public_ip                = lower(vm.enable_public_ip) == "true"
      subnet_name                     = vm.subnet_name

      application_security_groups = (vm.application_security_groups == "" ? [] : split(";", vm.application_security_groups))

      nic_info = {
        private_ip_address            = vm.private_ip_address
        private_ip_address_allocation = vm.private_ip_address_allocation
      }
      source_image_reference = {
        publisher = vm.image_publisher
        offer     = vm.image_offer
        sku       = vm.image_sku
        version   = vm.image_version
      }
      os_disk = {
        # caching              = vm.os_disk_caching
        storage_account_type = vm.os_disk_storage_account_type
        disk_size_gb         = try(tonumber(vm.os_disk_size_gb), 64)
      }
      auto_shutdown = vm.shutdown_time == "" ? null : {
        time           = vm.shutdown_time
        timezone       = vm.shutdown_timezone
        notify         = vm.shutdown_notify == "" ? false : lower(vm.shutdown_notify) == "true"
        notify_minutes = vm.shutdown_notify_minutes == "" ? null : tonumber(vm.shutdown_notify_minutes)
        email          = vm.shutdown_email == "" ? null : vm.shutdown_email
      }
    }
  }
}
