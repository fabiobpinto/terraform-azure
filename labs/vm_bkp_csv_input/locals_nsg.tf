###############################################################
# Network Security Group CSV
###############################################################
locals {
  csv_nsg = csvdecode(file("${path.module}/data/03-nsg_rules.csv"))
  csv_nsg_rules = {
    for nsg in distinct([
      for rule in local.csv_nsg : rule.nsg_name
    ]) :
    nsg => [
      for rule in local.csv_nsg : {
        name                                        = rule.name
        priority                                    = tonumber(rule.priority)
        direction                                   = rule.direction
        access                                      = rule.access
        protocol                                    = rule.protocol
        source_port_range                           = rule.source_port_range
        destination_port_range                      = rule.destination_port_range
        source_address_prefix                       = (rule.source_application_security_groups == "" ? rule.source_address_prefix : null)
        destination_address_prefix                  = (rule.destination_application_security_groups == "" ? rule.destination_address_prefix : null)
        source_application_security_group_ids       = []
        destination_application_security_group_ids  = []
        source_application_security_group_keys      = (rule.source_application_security_groups == "" ? [] : split(";", rule.source_application_security_groups))
        destination_application_security_group_keys = (rule.destination_application_security_groups == "" ? [] : split(";", rule.destination_application_security_groups))
      }
      if rule.nsg_name == nsg
    ]
  }
}
