resource "azurerm_bastion_host" "bastion" {
  name                = var.bastion_name
  location            = var.location
  resource_group_name = var.rg_name

  copy_paste_enabled        = var.bastion.copy_paste_enabled
  file_copy_enabled         = var.bastion.file_copy_enabled
  ip_connect_enabled        = var.bastion.ip_connect_enabled
  kerberos_enabled          = var.bastion.kerberos_enabled
  scale_units               = var.bastion.scale_units
  session_recording_enabled = var.bastion.session_recording_enabled
  shareable_link_enabled    = var.bastion.shareable_link_enabled
  sku                       = var.bastion.sku
  tunneling_enabled         = var.bastion.tunneling_enabled
  virtual_network_id        = var.bastion.virtual_network_id

  ip_configuration {
    name                 = "configuration-${var.bastion_name}"
    subnet_id            = var.bastion_subnet_id
    public_ip_address_id = var.public_ip_address_id
  }
  tags = var.tags

  timeouts {
    create = "60m"
    delete = "60m"
    update = "60m"
  }

}