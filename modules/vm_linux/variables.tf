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
    admin_pass                  = string
    vm_name                            = string
    vm_size                            = string
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

}

####
variable "nic_info" {
  type = object({
    name = string
    ip_configuration = object({
      name                                               = string
      subnet_id                                          = optional(string, null)
      private_ip_address_allocation                      = string
      private_ip_address                                 = optional(string, null)

    })
  })
}