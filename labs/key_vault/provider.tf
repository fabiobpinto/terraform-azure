terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.58.0"
    }
  }
}
provider "azurerm" {
  features {
    virtual_machine {
      detach_implicit_data_disk_on_deletion = false
      delete_os_disk_on_deletion            = true
      skip_shutdown_and_force_delete        = false
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
  subscription_id = var.subscription_id
}
