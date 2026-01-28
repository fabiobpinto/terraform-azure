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

variable "vm_linux" {
  type = object({
    admin_username                  = string
    admin_pass                      = string
    vm_name                         = string
    computer_name                   = string
    vm_size                         = string
    disable_password_authentication = bool

    os_disk = object({
      caching              = string
      storage_account_type = string
      disk_size_gb         = optional(number, 30)
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

variable "nic_info" {
  type = object({
    name = string
    ip_configuration = object({
      name                          = string
      subnet_id                     = optional(string, null)
      private_ip_address_allocation = string
      private_ip_address            = optional(string, null)

    })
  })
  description = "Configuration object for the Network Interface Card (NIC)."
}

variable "public_ip_id" {
  type        = string
  default     = null
  description = "The ID of the Public IP to associate with the VM's NIC."
}

variable "auto_shutdown" {
  type = object({
    enabled        = bool
    time           = string
    timezone       = string
    notify         = bool
    notify_minutes = number
    email          = string
  })
  description = "Configuration object for the VM auto-shutdown feature."
}