########################################################################
### Backup Policies
########################################################################
module "backup" {
  source   = "../../modules/backup_vault"
  for_each = local.csv_backup_policies
  rg_name  = module.rg.rg_name
  location = module.rg.location

  recovery_vault = each.value.recovery_vault
  backup_policy  = each.value.backup_policy

  source_vm_id = local.csv_backup_assignments[each.key]

  tags = local.tags

}
