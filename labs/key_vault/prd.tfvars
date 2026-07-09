rg_name  = "rg-keyvault-prd"
location = "East US"
########################################################################
### Tags to apply to all resources
tags = {
  environment = "prd"
  owner       = "Fabio Brito Pinto"
  project     = "Azure Key Vault Lab"
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
### Virtual Machines Linux
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

  }
}

########################################################################
### Key Vaults configuration
########################################################################
key_vaults = {
  kv-linuxweb01 = {
    name                          = "kv-linuxweb01-prd"
    public_network_access_enabled = true
    network_acls = {
      default_action = "Allow"
    }
    private_endpoints = {
      default = {
        name               = "pep-kv-linuxweb01"
        subnet_name        = "web"
        private_ip_address = "10.0.1.201"
      }
    }
  }
  kv-linuxweb02 = {
    name                          = "kv-linuxweb02-prd"
    public_network_access_enabled = true
    network_acls = {
      default_action = "Allow"
    }
    private_endpoints = {
      default = {
        name               = "pep-kv-linuxweb02"
        subnet_name        = "web"
        private_ip_address = "10.0.1.202"
      }
    }
  }
}
