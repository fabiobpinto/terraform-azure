rg_name  = "rg-dns"
location = "East US"
########################################################################
### Tags to apply to all resources
########################################################################
tags = {
  environment = "test"
  owner       = "Fabio Brito Pinto"
  project     = "Network Connect Lab"
}

########################################################################
### Virtual Network and Subnets configuration
########################################################################
vnet_name          = "vnet"
vnet_address_space = ["10.0.0.0/16"]

subnets = {
  endpoint = {
    name             = "snet-endpoint"
    address_prefixes = ["10.0.10.0/24"]
    rule             = "endpoint"
  },
  web = {
    name             = "snet-web"
    address_prefixes = ["10.0.20.0/24"]
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
      name                   = "Allow-SSH"
      priority               = 1030
      direction              = "Inbound"
      destination_port_range = "22"
    }
  ]
  endpoint = [
    {
      name                   = "Allow-Storage"
      priority               = 1030
      direction              = "Inbound"
      destination_port_range = "443"
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
      private_ip_address            = "10.0.20.10"
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


#########################################################################
### Storage Accounts
#########################################################################

storage_accounts = {
  labstorage01 = {
    name                              = "stlabpefabio001"
    account_kind                      = "StorageV2"
    account_tier                      = "Standard"
    account_replication_type          = "LRS"
    access_tier                       = "Hot"
    min_tls_version                   = "TLS1_2"
    public_network_access_enabled     = false
    shared_access_key_enabled         = true
    allow_nested_items_to_be_public   = false
    infrastructure_encryption_enabled = false
    default_to_oauth_authentication   = true

    containers = [
      {
        name                  = "lab"
        container_access_type = "private"
      },
      {
        name                  = "files"
        container_access_type = "private"
      }
    ]


    file_shares = [
      {
        name  = "labshare"
        quota = 5
      }
    ]


    blob_properties = {
      versioning_enabled       = false
      change_feed_enabled      = false
      last_access_time_enabled = false
      delete_retention_policy = {
        days = 7
      }
      container_delete_retention_policy = {
        days = 7
      }
    }

    create_private_dns_zones             = true
    private_dns_zone_resource_group_name = null
    existing_private_dns_zone_ids        = {}

    private_endpoints = {
      blob = {
        name                            = "pep-stlabpefabio001-blob"
        subnet_name                     = "endpoint"
        private_ip_address              = "10.0.10.50"
        subresource_name                = "blob"
        private_dns_zone_names          = ["blob"]
        private_service_connection_name = "psc-stlabpefabio001-blob"
        private_dns_zone_group_name     = "pdzg-stlabpefabio001-blob"
        ip_configuration_name           = "ipconfig-stlabpefabio001-blob"
        is_manual_connection            = false
        tags = {
          subresource = "blob"
        }
      }
    }
  }
}
