###############################################################
# Network Security Group CSV
###############################################################
locals {
  bastion_csv = csvdecode(file("${path.module}/data/08-bastion.csv"))
  bastions = {
    for bastion in local.bastion_csv :
    bastion.bastion_name => {
      bastion_name              = bastion.bastion_name
      vnet_name                 = bastion.vnet_name
      subnet_name               = bastion.subnet_name
      public_ip_name            = bastion.public_ip_name
      sku                       = bastion.sku
      scale_units               = tonumber(bastion.scale_units)
      copy_paste_enabled        = lower(bastion.copy_paste) == "true"
      file_copy_enabled         = lower(bastion.file_copy) == "true"
      ip_connect_enabled        = lower(bastion.ip_connect) == "true"
      kerberos_enabled          = lower(bastion.kerberos) == "true"
      shareable_link_enabled    = lower(bastion.shareable_link) == "true"
      tunneling_enabled         = lower(bastion.tunneling) == "true"
      session_recording_enabled = lower(bastion.session_recording) == "true"
    }
  }
}
