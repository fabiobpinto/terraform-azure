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
  csv_virtual_network = {
    vnet_name          = local.network_csv[0].vnet_name
    vnet_address_space = [local.network_csv[0].vnet_address_space]
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
    }
  }
}
