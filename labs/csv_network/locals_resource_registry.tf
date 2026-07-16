########################################################################
### Resource Registry
########################################################################
#
# Este arquivo centraliza a resolução de nomes lógicos para Resource IDs.
#
# Objetivos:
#
# - Evitar armazenar IDs do Azure em arquivos CSV.
# - Permitir que módulos consultem recursos apenas pelo nome.
# - Centralizar todas as referências entre módulos.
# - Facilitar reutilização e expansão da Landing Zone.
#
# Padrão das chaves:
#
# <TipoDoRecurso>:<NomeDoRecurso>
#
# Exemplos:
#
# VirtualNetwork:vnet-prd
# Subnet:vnet-prd/snet-web
# NetworkSecurityGroup:nsg-web
# ApplicationSecurityGroup:asg-web
# VirtualHub:hub-eastus
# VirtualHubConnection:connection-prd
# RecoveryServicesVault:rsv-prd
# BackupPolicy:daily
#
########################################################################

locals {

  resource_registry = merge(

    ####################################################################
    # Virtual Networks
    ####################################################################
    {
      for name, network in module.network :
      "VirtualNetwork:${name}" => network.vnet_id
    },

    ####################################################################
    # Subnets
    ####################################################################
    merge([
      for vnet_name, network in module.network : {
        for subnet_name, subnet_id in network.subnet_ids :
        "Subnet:${vnet_name}/${subnet_name}" => subnet_id
      }
    ]...),

    ####################################################################
    # Application Security Groups
    ####################################################################
    {
      for name, asg in module.asg :
      "ApplicationSecurityGroup:${name}" => asg.id
    },

    ####################################################################
    # Network Security Groups
    ####################################################################
    {
      for name, nsg in module.nsg_csv :
      "NetworkSecurityGroup:${name}" => nsg.id
    },

    ####################################################################
    # Virtual WAN
    ####################################################################
    {
      for name, wan in module.virtual_wan :
      "VirtualWan:${name}" => wan.virtual_wan_id
    },

    ####################################################################
    # Virtual Hub
    ####################################################################
    {
      for name, hub in module.virtual_hub :
      "VirtualHub:${name}" => hub.virtual_hub_id
    },

    ####################################################################
    # Virtual Hub Connections
    ####################################################################
    {
      for name, connection in module.virtual_hub_connection :
      "VirtualHubConnection:${name}" => connection.virtual_hub_connection_id
    },

    ####################################################################
    # Backup Vault
    ####################################################################
    # Descomentar quando o módulo utilizar for_each.
    #
    # {
    #   for name, backup in module.backup :
    #   "RecoveryServicesVault:${name}" => backup.recovery_vault_id
    # },

    ####################################################################
    # Backup Policies
    ####################################################################
    # {
    #   for name, backup in module.backup :
    #   "BackupPolicy:${name}" => backup.backup_policy_id
    # },

    ####################################################################
    # Azure Firewall
    ####################################################################
    # {
    #   for name, firewall in module.azure_firewall :
    #   "AzureFirewall:${name}" => firewall.id
    # },

    ####################################################################
    # Firewall Policies
    ####################################################################
    # {
    #   for name, policy in module.firewall_policy :
    #   "FirewallPolicy:${name}" => policy.id
    # },

    ####################################################################
    # VPN Gateway
    ####################################################################
    # {
    #   for name, gateway in module.vpn_gateway :
    #   "VPNGateway:${name}" => gateway.id
    # },

    ####################################################################
    # ExpressRoute Gateway
    ####################################################################
    # {
    #   for name, gateway in module.expressroute_gateway :
    #   "ExpressRouteGateway:${name}" => gateway.id
    # },

    ####################################################################
    # Azure Bastion
    ####################################################################
    # {
    #   for name, bastion in module.bastion :
    #   "Bastion:${name}" => bastion.id
    # },

    ####################################################################
    # NAT Gateway
    ####################################################################
    # {
    #   for name, nat in module.nat_gateway :
    #   "NatGateway:${name}" => nat.id
    # },

    ####################################################################
    # Route Tables
    ####################################################################
    # {
    #   for name, rt in module.route_table :
    #   "RouteTable:${name}" => rt.id
    # },

    ####################################################################
    # Load Balancers
    ####################################################################
    # {
    #   for name, lb in module.load_balancer :
    #   "LoadBalancer:${name}" => lb.id
    # },

    ####################################################################
    # Private DNS Zones
    ####################################################################
    # {
    #   for name, zone in module.private_dns_zone :
    #   "PrivateDnsZone:${name}" => zone.id
    # },

    ####################################################################
    # Private Endpoints
    ####################################################################
    # {
    #   for name, pe in module.private_endpoint :
    #   "PrivateEndpoint:${name}" => pe.id
    # },

    ####################################################################
    # Storage Accounts
    ####################################################################
    # {
    #   for name, sa in module.storage_account :
    #   "StorageAccount:${name}" => sa.id
    # },

    ####################################################################
    # Key Vaults
    ####################################################################
    # {
    #   for name, kv in module.key_vault :
    #   "KeyVault:${name}" => kv.id
    # },

    ####################################################################
    # Managed Identities
    ####################################################################
    # {
    #   for name, mi in module.managed_identity :
    #   "ManagedIdentity:${name}" => mi.id
    # }

  )

}
