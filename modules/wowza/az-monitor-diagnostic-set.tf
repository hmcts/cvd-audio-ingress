resource "azurerm_monitor_diagnostic_setting" "cvp-kv-diag-set" {
  name                       = "cvp-kv-${var.env}-diag-set"
  target_resource_id         = data.azurerm_key_vault.cvp_kv.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics.id

  log {
    category = "AuditEvent"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
    }
  }
}


// resource "azurerm_monitor_diagnostic_setting" "cvp-vm1-diag-set" {
//  name               = "cvp-vm1-${var.env}-diag-set"
//  target_resource_id = azurerm_linux_virtual_machine.vm1.id
//  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics.id

//  metric {
//    category = "AllMetrics"
//    enabled  = true
//  }
// }

// resource "azurerm_monitor_diagnostic_setting" "cvp-vm2-diag-set" {
//  name               = "cvp-vm2-${var.env}-diag-set"
//  target_resource_id = azurerm_linux_virtual_machine.vm2.id
//  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics.id

//  metric {
//    category = "AllMetrics"
//    enabled  = true
//  }
// }

resource "azurerm_monitor_diagnostic_setting" "cvp-sa-diag-set" {
  name                       = "cvp-sa-${var.env}-diag-set"
  target_resource_id         = module.sa.storageaccount_id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics.id

  metric {
    category = "Capacity"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
  metric {

    category = "Transaction"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "cvp-pipvm1-diag-set" {
  name                       = "cvp-pipvm1-${var.env}-diag-set"
  target_resource_id         = azurerm_public_ip.pip_vm1.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics.id

  log {
    category = "DDoSProtectionNotifications"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "DDoSMitigationFlowLogs"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "DDoSMitigationReports"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "cvp-pipvm2-diag-set" {
  name                       = "cvp-pipvm2-${var.env}-diag-set"
  target_resource_id         = azurerm_public_ip.pip_vm2.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics.id

  log {
    category = "DDoSProtectionNotifications"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "DDoSMitigationFlowLogs"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "DDoSMitigationReports"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "cvp-nsg-diag-set" {
  name                       = "cvp-nsg-${var.env}-diag-set"
  target_resource_id         = azurerm_network_security_group.sg.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics.id

  log {
    category = "NetworkSecurityGroupEvent"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "NetworkSecurityGroupRuleCounter"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "cvp-nic1-diag-set" {
  name                       = "cvp-nic1-${var.env}-diag-set"
  target_resource_id         = azurerm_network_interface.nic1.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics.id

  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "cvp-nic2-diag-set" {
  name                       = "cvp-nic2-${var.env}-diag-set"
  target_resource_id         = azurerm_network_interface.nic2.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics.id

  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "cvp-lb-diag-set" {
  name                       = "cvp-lb-${var.env}-diag-set"
  target_resource_id         = azurerm_lb.lb.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics.id

  log {
    category = "LoadBalancerAlertEvent"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "LoadBalancerProbeHealthStatus"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
}