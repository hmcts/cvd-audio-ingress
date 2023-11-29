#---------------------------------------------------
# VM backup policy
#---------------------------------------------------
resource "azurerm_backup_policy_vm" "vm_backup" {
  count = var.env == "prod" ? 1 : 0

  name = "${local.service_name}-rsv-policy"

  resource_group_name            = azurerm_resource_group.rg.name
  recovery_vault_name            = azurerm_recovery_services_vault.backup_vault[0].name
  timezone                       = "UTC"
  instant_restore_retention_days = 5

  backup {
    frequency = "Weekly"
    time      = "20:00"
    weekdays  = ["Sunday"]
  }

  retention_weekly {
    count    = 1
    weekdays = ["Sunday"]
  }
}

