rg_name  = "rg-prd-backup-vm"
location = "East US"
########################################################################
### Tags to apply to all resources
tags = {
  environment = "prd"
  owner       = "Fabio Brito Pinto"
  project     = "Azure Backup VM Lab"
}

########################################################################
### Virtual Network and Subnets configuration
########################################################################
vnet_name          = "vnet-prd"
vnet_address_space = ["10.0.0.0/16"]

subnets = {
  web = {
    name             = "snet-prd-web"
    address_prefixes = ["10.0.1.0/24"]
    rule             = "web"
  }
}

########################################################################
### Network Security Group Rules
########################################################################
nsg_name = "nsg-prd"
nsg_rules = {
  web = [
    {
      name                       = "Allow-AzureLoadBalancer"
      priority                   = 1005
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_address_prefix      = "AzureLoadBalancer"
      destination_port_range     = "80"
      destination_address_prefix = "*"
    },
    {
      name                   = "Allow-HTTP"
      priority               = 1010
      direction              = "Inbound"
      destination_port_range = "80"
    },
    {
      name                   = "Allow-HTTPS"
      priority               = 1020
      direction              = "Inbound"
      destination_port_range = "443"
    },
    {
      name                       = "Allow-All-Internet-Outbound"
      priority                   = 1000
      direction                  = "Outbound"
      destination_port_range     = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "Internet"
      protocol                   = "*"
    }
  ]
}

########################################################################
# Virtual Machines
########################################################################
admin_username = "adminfabio"

vms_linux_web = {
  linuxweb01 = {
    admin_username                  = "adminfabio"
    disable_password_authentication = false
    name                            = "linuxweb01"
    computer_name                   = "linuxweb01"
    size                            = "Standard_DS1_v2"
    enable_public_ip                = true
    enable_auto_shutdown            = true

    source_image_reference = {
      publisher = "RedHat"
      offer     = "RHEL"
      sku       = "83-gen2"
      version   = "latest"
    }

    os_disk = {
      caching              = "ReadWrite"
      storage_account_type = "Premium_LRS"
      disk_size_gb         = 64
    }

    nic_ip_configuration_name = "primary"
    subnet_name               = "snet-prd-web"

    nic_info = {
      private_ip_address            = "10.0.1.10"
      private_ip_address_allocation = "Static"
    }

    auto_shutdown = {
      time           = "1900"
      timezone       = "E. South America Standard Time"
      notify         = false
      notify_minutes = 30
      email          = null
    }

  },
  linuxweb02 = {
    admin_username                  = "adminfabio"
    disable_password_authentication = false
    name                            = "linuxweb02"
    computer_name                   = "linuxweb02"
    size                            = "Standard_DS1_v2"
    enable_public_ip                = false
    enable_auto_shutdown            = false

    source_image_reference = {
      publisher = "RedHat"
      offer     = "RHEL"
      sku       = "83-gen2"
      version   = "latest"
    }

    os_disk = {
      caching              = "ReadWrite"
      storage_account_type = "Premium_LRS"
      disk_size_gb         = 64
    }

    nic_ip_configuration_name = "primary"
    subnet_name               = "snet-prd-web"

    nic_info = {
      private_ip_address            = "10.0.1.11"
      private_ip_address_allocation = "Static"
    }
  },
  linuxweb03 = {
    admin_username                  = "adminfabio"
    disable_password_authentication = false
    name                            = "linuxweb03"
    computer_name                   = "linuxweb03"
    size                            = "Standard_DS1_v2"
    enable_public_ip                = false
    enable_auto_shutdown            = false

    source_image_reference = {
      publisher = "RedHat"
      offer     = "RHEL"
      sku       = "83-gen2"
      version   = "latest"
    }

    os_disk = {
      caching              = "ReadWrite"
      storage_account_type = "Premium_LRS"
      disk_size_gb         = 64
    }

    nic_ip_configuration_name = "primary"
    subnet_name               = "snet-prd-web"

    nic_info = {
      private_ip_address            = "10.0.1.12"
      private_ip_address_allocation = "Static"
    }
  }
}


backup_policies = {
  daily = {
    recovery_vault = {
      name                = "rsv-prd-daily"
      sku                 = "Standard"
      soft_delete_enabled = true
      storage_mode_type   = "LocallyRedundant"
    }
    backup_policy = {
      name     = "daily-policy"
      timezone = "UTC"
      backup = {
        frequency = "Daily"
        time      = "11:00"
      }
      retention_daily = {
        count = 30
      }
      retention_weekly = {
        count    = 8
        weekdays = ["Sunday"]
      }
      retention_monthly = {
        count    = 12
        weekdays = ["Sunday"]
        weeks    = ["First"]
      }
      retention_yearly = {
        count    = 5
        weekdays = ["Sunday"]
        weeks    = ["First"]
        months   = ["January"]
      }
    }
  }
  weekly = {
    recovery_vault = {
      name                           = "rsv-prd-weekly"
      sku                            = "Standard"
      soft_delete_enabled            = true
      instant_restore_retention_days = 5
    }
    backup_policy = {
      name     = "weekly-policy"
      timezone = "UTC"

      backup = {
        frequency = "Weekly"
        time      = "11:00"
        weekdays  = ["Sunday"]
      }
      retention_daily = {
        count = 7
      }
      retention_weekly = {
        count    = 52
        weekdays = ["Sunday"]
      }
      retention_monthly = {
        count    = 24
        weekdays = ["Sunday"]
        weeks    = ["Last"]
      }
      retention_yearly = {
        count    = 10
        weekdays = ["Sunday"]
        weeks    = ["Last"]
        months   = ["December"]
      }
    }
  }
}
