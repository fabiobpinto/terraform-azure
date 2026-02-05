rg_name  = "rg-prd-loadbalancer"
location = "East US"
########################################################################
### Tags to apply to all resources
tags = {
  environment = "prd"
  owner       = "Fabio Brito Pinto"
  project     = "Azure Load Balancer Lab"
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
      name                   = "Allow-SSH"
      priority               = 1030
      direction              = "Inbound"
      destination_port_range = "22"
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
    enable_public_ip                = false

    source_image_reference = {
      publisher = "Canonical"
      offer     = "ubuntu-24_04-lts"
      sku       = "server"
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
  },
  linuxweb02 = {
    admin_username                  = "adminfabio"
    disable_password_authentication = false
    name                            = "linuxweb02"
    computer_name                   = "linuxweb02"
    size                            = "Standard_DS1_v2"
    enable_public_ip                = false

    source_image_reference = {
      publisher = "Canonical"
      offer     = "ubuntu-24_04-lts"
      sku       = "server"
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
  }
}

########################################################################
# Load Balancer
########################################################################
loadbalancer = {
  lb-web = {
    sku                            = "Standard"
    frontend_ip_configuration_name = "frontend-ip-config"
  }
}
