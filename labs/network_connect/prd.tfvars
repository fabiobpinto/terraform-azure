rg_name  = "rg-network-connect"
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
  app = {
    name             = "snet-app"
    address_prefixes = ["10.0.10.0/24"]
    rule             = "app"
  },
  web = {
    name             = "snet-web"
    address_prefixes = ["10.0.20.0/24"]
    rule             = "web"
  }

}

########################################################################
### Virtual WAN configuration
########################################################################

wan_name = "virtual-wan"

########################################################################
### Virtual Hub configuration
########################################################################
vhub_name          = "virtual-hub-01"
hub_address_prefix = "10.1.0.0/24"


########################################################################
### Virtual Hub Route Table configuration
########################################################################

route_table_name = "example-vhubroutetable"
route_table_labels = [
  "default"
]
routes = [
  {
    name              = "route-vnet-01"
    destinations_type = "CIDR"
    destinations = [
      "10.0.0.0/16"
    ]
    next_hop_type = "ResourceId"
  },
  {
    name              = "route-vnet-02"
    destinations_type = "CIDR"
    destinations = [
      "10.1.0.0/16"
    ]
    next_hop_type = "ResourceId"
  }
]
