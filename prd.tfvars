rg_name  = "rg-prd-real-world"
location = "East US"

### Tags to apply to all resources
tags = {
  environment = "prd"
  owner       = "Fabio Brito Pinto"
  project     = "Azure Real World"
}

### Virtual Network and Subnets configuration
vnet_name          = "vnet-prd"
vnet_address_space = ["10.0.0.0/16"]

subnets = {
  web = {
    name             = "snet-prd-web"
    address_prefixes = ["10.0.1.0/24"]
    rule             = "web"
  }
  app = {
    name             = "snet-prd-app"
    address_prefixes = ["10.0.11.0/24"]
    rule             = "app"
  }
  db = {
    name             = "snet-prd-db"
    address_prefixes = ["10.0.21.0/24"]
    rule             = "db"
  }
  bastion = {
    name             = "AzureBastionSubnet"
    address_prefixes = ["10.0.100.0/26"]
    rule             = "bastion"
  }
}

### Network Security Group Rules
#####################################################
# Variables for Network Security Group and Rules
#####################################################
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

  app = [
    {
      name                   = "Allow-App"
      priority               = 1010
      direction              = "Inbound"
      destination_port_range = "8080"
    },
    {
      name                   = "Allow-SSH"
      priority               = 1020
      direction              = "Inbound"
      destination_port_range = "22"
    }
  ]

  db = [
    {
      name                   = "Allow-MySQL"
      priority               = 1010
      direction              = "Inbound"
      destination_port_range = "3306"
    }
  ]

  bastion = [
    {
      name                       = "Allow-HTTPS-In"
      priority                   = 1010
      direction                  = "Inbound"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
    },
    {
      name                       = "Allow-SSH-Out"
      priority                   = 1110
      direction                  = "Outbound"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "VirtualNetwork"
    },
    {
      name                       = "Allow-RDP-Out"
      priority                   = 1120
      direction                  = "Outbound"
      destination_port_range     = "3389"
      source_address_prefix      = "*"
      destination_address_prefix = "VirtualNetwork"
    },
    {
      name                       = "Allow-Azure-Out"
      priority                   = 1130
      direction                  = "Outbound"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "AzureCloud"
    }
  ]
}

#VMs
# Virtual Machines
admin_username = "adminfabio"

vms_linux_app = {
  linuxapp01 = {
    admin_username                  = "adminfabio"
    disable_password_authentication = false
    name                            = "linuxapp01"
    size                            = "Standard_DS1_v2"
    enable_public_ip                = true
    pip_name                        = "linuxapp01-pip"

    source_image_reference = {
      publisher = "RedHat"
      offer     = "RHEL"
      sku       = "9-lvm-gen2"
      version   = "latest"
    }

    os_disk = {
      caching              = "ReadWrite"
      storage_account_type = "Premium_LRS"
      disk_size_gb         = 64
    }

    nic_ip_configuration_name = "primary"
    subnet_name               = "snet-prd-app"

    nic_info = {
      private_ip_address            = "10.0.11.10"
      private_ip_address_allocation = "Static"
    }
  }
}

vms_linux_web = {
  linuxweb01 = {
    admin_username                  = "adminfabio"
    disable_password_authentication = false
    name                            = "linuxweb01"
    size                            = "Standard_DS1_v2"

    source_image_reference = {
      publisher = "RedHat"
      offer     = "RHEL"
      sku       = "9-lvm-gen2"
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
  }
}