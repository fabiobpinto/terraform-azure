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
  },
  ansible = {
    name             = "snet-prd-ansible"
    address_prefixes = ["10.0.2.0/24"]
    rule             = "ansible"
  },
  loadbalancer = {
    name             = "snet-prd-loadbalancer"
    address_prefixes = ["10.0.250.0/24"]
    rule             = "loadbalancer"
  }
}

########################################################################
### Network Security Group Rules
########################################################################
nsg_name = "nsg-prd"
nsg_rules = {
  ansible = [
    {
      name                   = "Allow-SSH"
      priority               = 1030
      direction              = "Inbound"
      destination_port_range = "22"
    }
  ]
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
      name                   = "Allow-SSH"
      priority               = 1030
      direction              = "Inbound"
      destination_port_range = "22"
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
  loadbalancer = [
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

vms_linux_ansible = {
  linuxansible01 = {
    admin_username                  = "adminfabio"
    disable_password_authentication = false
    name                            = "linuxansible01"
    computer_name                   = "linuxansible01"
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
    subnet_name               = "snet-prd-ansible"

    nic_info = {
      private_ip_address            = "10.0.2.10"
      private_ip_address_allocation = "Static"
    }
  }
}

vms_linux_web = {
  linuxweb01 = {
    admin_username                  = "adminfabio"
    disable_password_authentication = false
    name                            = "linuxweb01"
    computer_name                   = "linuxweb01"
    size                            = "Standard_DS1_v2"
    enable_public_ip                = false

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
  },
  linuxweb02 = {
    admin_username                  = "adminfabio"
    disable_password_authentication = false
    name                            = "linuxweb02"
    computer_name                   = "linuxweb02"
    size                            = "Standard_DS1_v2"
    enable_public_ip                = false

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
  }
}

########################################################################
# Load Balancer
########################################################################
loadbalancer_public = {
  prd-loadbalancer01 = {
    name     = "lb-external-01"
    sku      = "Standard"
    sku_tier = "Regional"

    frontend_ip_configuration = {
      frontendip = {
        name = "frontend"
      }
    }

    lb_probes = {
      http = {
        name                = "http-80"
        port                = 80
        protocol            = "Http"
        interval_in_seconds = 15
        probe_threshold     = 2
        request_path        = "/"
      }
    }

    lb_rules = {
      http_rule = {
        name          = "http"
        protocol      = "Tcp"
        frontend_port = 80
        backend_port  = 80
        probe_key     = "http"
      }
    }

    lb_nat_rules = {
      ssh_linuxweb01 = {
        name          = "ssh-1022-linuxweb01"
        protocol      = "Tcp"
        frontend_port = 1021
        backend_port  = 22
        target_vm     = "linuxweb01"
      }

      ssh_linuxweb02 = {
        name          = "ssh-1023-linuxweb02"
        protocol      = "Tcp"
        frontend_port = 1023
        backend_port  = 22
        target_vm     = "linuxweb02"
      }
    }



  }
}

loadbalancer_private = {
  prd-loadbalancer02 = {
    name     = "lb-internal-01"
    sku      = "Standard"
    sku_tier = "Regional"

    frontend_ip_configuration = {
      frontendip = {
        name                          = "frontend"
        private_ip_address_allocation = "Static"
        private_ip_address            = "10.0.250.10"
      }
    }
    lb_probes = {
      http = {
        name                = "http-80"
        port                = 80
        protocol            = "Http"
        interval_in_seconds = 15
        probe_threshold     = 2
        request_path        = "/"
      }
    }

    lb_rules = {
      http_rule = {
        name          = "http"
        protocol      = "Tcp"
        frontend_port = 80
        backend_port  = 80
        probe_key     = "http"
      }
    }
  }
}