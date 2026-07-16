########################################################################
### Network Security Group
########################################################################
module "nsg_csv" {
  source                         = "../../modules/network_security_group"
  rg_name                        = module.rg.rg_name
  location                       = module.rg.location
  tags                           = local.tags
  for_each                       = local.csv_nsg_rules
  nsg_name                       = each.key
  nsg_rules                      = each.value
  application_security_group_ids = { for name, asg in module.asg : name => asg.id }
}

########################################################################
### Network Security Group Association
########################################################################
resource "azurerm_subnet_network_security_group_association" "this" {
  for_each                  = local.network.subnets
  subnet_id                 = module.network.subnet_ids[each.key]
  network_security_group_id = module.nsg_csv[each.value.nsg_name].id
}
