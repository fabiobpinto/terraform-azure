########################################################################
### Public IP for Bastion
########################################################################
module "public_ip_bastion" {
  source = "../../modules/public_ip"

  for_each = local.bastions

  rg_name  = module.rg.rg_name
  location = module.rg.location
  tags     = local.tags

  pip_name = each.value.public_ip_name

}

########################################################################
### Virtual Network
########################################################################
module "bastion" {

  source = "../../modules/bastion"

  for_each = local.bastions

  rg_name  = module.rg.rg_name
  location = module.rg.location
  tags     = local.tags

  bastion_name         = each.value.bastion_name
  public_ip_address_id = module.public_ip_bastion[each.key].public_ip_id
  bastion_subnet_id    = module.network[each.value.vnet_name].subnet_ids[each.value.subnet_name]
  bastion = {
    sku                       = each.value.sku
    scale_units               = each.value.scale_units
    copy_paste_enabled        = each.value.copy_paste_enabled
    file_copy_enabled         = each.value.file_copy_enabled
    ip_connect_enabled        = each.value.ip_connect_enabled
    kerberos_enabled          = each.value.kerberos_enabled
    shareable_link_enabled    = each.value.shareable_link_enabled
    tunneling_enabled         = each.value.tunneling_enabled
    session_recording_enabled = each.value.session_recording_enabled
  }
}
