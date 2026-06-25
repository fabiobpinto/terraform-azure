variable "rg_name" {
  type        = string
  description = "The name of the resource group."
}

variable "location" {
  type        = string
  description = "The Azure region where the resources will be deployed."
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource group."
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet where the virtual machine will be deployed."
}

variable "vmss_linux" {
  type = object({
    admin_username = string
    vm_name        = string
    sku            = string
    instances      = number

    os_disk = object({
      caching              = string
      storage_account_type = string
      disk_size_gb         = optional(number, 50)
    })

    source_image_reference = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
  })
  description = "Configuration object for the Linux virtual machine."
}

variable "application_security_group_ids" {
  type        = list(string)
  default     = []
  description = "Application Security Group IDs to associate with the VM's NIC."
}

variable "load_balancer_backend_address_pool_ids" {
  type        = list(string)
  default     = []
  description = "Load Balancer Backend Address Pool IDs to associate with the VM's NIC."
}
