# Resource Group
module "rg" {
  source   = "./modules/resource_group"
  rg_name  = var.rg_name
  location = var.location
  tags     = var.tags
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "VNET01"
  address_space       = ["10.0.0.0/16"]
  location            = module.rg.location
  resource_group_name = module.rg.rg_name
  tags                = var.tags
}

# Virtual Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "SUBNET01"
  resource_group_name  = module.rg.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP
resource "azurerm_public_ip" "public_ip" {
  name                = "PUBLICIP01"
  resource_group_name = module.rg.rg_name
  location            = module.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "NIC01"
  location            = module.rg.location
  resource_group_name = module.rg.rg_name

  ip_configuration {
    name                          = "IPCONFIG01"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  tags = var.tags
}