locals {
  ###############################################################
  # Backup CSV
  ###############################################################
  backup_policy_csv     = csvdecode(file("${path.module}/data/06-backup_policies.csv"))
  backup_assignment_csv = csvdecode(file("${path.module}/data/07-backup_assignments.csv"))

  ###############################################################
  # Backup Policies
  ###############################################################
  csv_backup_policies = {
    for policy in local.backup_policy_csv :
    policy.policy_name => {
      recovery_vault = {
        name                = policy.vault_name
        sku                 = policy.sku
        soft_delete_enabled = lower(policy.soft_delete_enabled) == "true"
        storage_mode_type   = policy.storage_mode_type
      }
      backup_policy = {
        name     = policy.policy_name
        timezone = policy.timezone
        backup = {
          frequency     = policy.frequency
          time          = policy.time
          weekdays      = (policy.backup_weekdays == "" ? null : split(",", policy.backup_weekdays))
          hour_interval = null
          hour_duration = null
        }
        retention_daily = {
          count = tonumber(policy.daily_count)
        }
        retention_weekly = {
          count    = tonumber(policy.weekly_count)
          weekdays = split(",", policy.weekly_days)
        }
        retention_monthly = {
          count    = tonumber(policy.monthly_count)
          weeks    = split(",", policy.monthly_weeks)
          weekdays = split(",", policy.monthly_days)
        }
        retention_yearly = {
          count    = tonumber(policy.yearly_count)
          weeks    = split(",", policy.yearly_weeks)
          weekdays = split(",", policy.yearly_days)
          months   = split(",", policy.yearly_months)
        }
      }
    }
  }

  ###############################################################
  # All Virtual Machines
  ###############################################################
  all_vm_ids = merge(
    {
      for k, v in module.vms_linux :
      k => v.vm_id
    },
    {
      for k, v in module.vms_windows :
      k => v.vm_id
    }
  )

  ###############################################################
  # Backup Assignments
  ###############################################################
  csv_backup_assignments = {
    for policy in keys(local.csv_backup_policies) :
    policy => {
      for assignment in local.backup_assignment_csv :
      assignment.vm_name => local.all_vm_ids[assignment.vm_name]
      if assignment.policy_name == policy
    }
  }

}
