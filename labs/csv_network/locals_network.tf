locals {

  ###############################################################
  # Delegation actions
  ###############################################################

  delegation_actions = {
    "Microsoft.ContainerInstance/containerGroups" = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Web/serverFarms"                   = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Sql/managedInstances"              = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.App/environments"                  = ["Microsoft.Network/virtualNetworks/subnets/action"]
  }

  ###############################################################
  # Network CSV
  ###############################################################
  network_csv = csvdecode(file("${path.module}/data/01-virtual_network.csv"))

  ###############################################################
  # Virtual Networks
  ###############################################################
  networks = {
    for vnet in distinct([
      for item in local.network_csv :
      item.vnet_name
    ]) :
    vnet => {
      vnet_name = vnet
      vnet_address_space = distinct([
        for item in local.network_csv :
        item.vnet_address_space
        if item.vnet_name == vnet
      ])
      subnets = {
        for subnet in local.network_csv :
        subnet.subnet_name => {
          name             = subnet.subnet_name
          address_prefixes = [subnet.address_prefix]
          nsg_name         = subnet.nsg_name
          delegation = subnet.delegation_service == "" ? null : {
            name = subnet.delegation_name
            service_delegation = {
              name    = subnet.delegation_service
              actions = lookup(local.delegation_actions, subnet.delegation_service, [])
            }
          }
        }
        if subnet.vnet_name == vnet
      }
    }
  }

  ###############################################################
  # Subnet NSG Associations
  ###############################################################
  subnet_nsg_associations = {
    for subnet in flatten([
      for vnet_name, vnet in local.networks : [
        for subnet_name, subnet in vnet.subnets : {
          key           = "${vnet_name}-${subnet_name}"
          vnet_name     = vnet_name
          subnet_name   = subnet_name
          subnet_id_key = subnet_name
          nsg_name      = subnet.nsg_name
        }
      ]
    ]) :
    subnet.key => subnet
    if try(trim(subnet.nsg_name), "") != ""
  }
}
