#---------------------------------------------------
# Diagnostic settings - KeyVault
#---------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "cvp-kv-diag-set" {
  name                       = "cvp-kv-${var.env}-diag-set"
  target_resource_id         = data.azurerm_key_vault.cvp_kv.id
  log_analytics_workspace_id = local.la_id

  metric {
    category = "AllMetrics"

  }
}

#---------------------------------------------------
# Diagnostic settings - Storage Account
#---------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "cvp-sa-diag-set" {
  name                       = "cvp-sa-${var.env}-diag-set"
  target_resource_id         = module.sa.storageaccount_id
  log_analytics_workspace_id = local.la_id

  metric {
    category = "Capacity"
    enabled  = true


  }
  metric {
    category = "Transaction"
    enabled  = true

  }
}

#---------------------------------------------------
# Diagnostic settings - NSG
#---------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "cvp-nsg-diag-set" {
  name                       = "cvp-nsg-${var.env}-diag-set"
  target_resource_id         = module.nsg.network_security_group_id
  log_analytics_workspace_id = local.la_id

  enabled_log {
    category = "NetworkSecurityGroupEvent"
  }

  enabled_log {
    category = "NetworkSecurityGroupRuleCounter"
  }
}

#---------------------------------------------------
# Diagnostic settings - Wowoza VM NIC
#---------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "cvp-nic-diag-set" {
  count = var.vm_count

  name                       = "cvp-nic${count.index + 1}-${var.env}-diag-set"
  target_resource_id         = azurerm_network_interface.wowza_nic[count.index].id
  log_analytics_workspace_id = local.la_id

  metric {
    category = "AllMetrics"
    enabled  = true

  }
}

#---------------------------------------------------
# Diagnostic settings - Load Balancer
#---------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "cvp-lb-diag-set" {
  name                       = "cvp-lb-${var.env}-diag-set"
  target_resource_id         = azurerm_lb.cvp.id
  log_analytics_workspace_id = local.la_id

  metric {
    category = "AllMetrics"
    enabled  = true

  }
}