rg_name  = "rg-prd-vmss"
location = "East US"
########################################################################
### Tags to apply to all resources
tags = {
  environment = "prd"
  owner       = "Fabio Brito Pinto"
  project     = "Azure Real World"
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
  vmss = {
    name             = "snet-prd-vmss"
    address_prefixes = ["10.0.31.0/24"]
    rule             = "web"
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
  web = [
    {
      name                                        = "Allow-HTTP-Web"
      priority                                    = 1000
      direction                                   = "Inbound"
      source_address_prefix                       = "Internet"
      destination_application_security_group_keys = ["web"]
      destination_port_range                      = "80"
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
  loadbalancer = [
    {
      name                                        = "Allow-HTTP-Web"
      priority                                    = 1000
      direction                                   = "Inbound"
      source_address_prefix                       = "Internet"
      destination_application_security_group_keys = ["web"]
      destination_port_range                      = "80"
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
}

#####################################################
### Application Security Group (ASG) Configuration
#####################################################
asgs = {
  web = {
    name = "asg-prd-web"
  }
}


########################################################################
# Virtual Machine Scale Set (VMSS) Configuration
########################################################################
vmss_linux = {
  vmss_linux01 = {
    vm_name        = "vmss-linux01"
    sku            = "Standard_D4_v5"
    instances      = 2
    admin_username = "azureuser"

    os_disk = {
      caching              = "ReadWrite"
      storage_account_type = "StandardSSD_LRS"
      disk_size_gb         = 64
    }

    source_image_reference = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts"
      version   = "latest"
    }
  }
}


# ########################################################################
# # Load Balancer
# ########################################################################
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
