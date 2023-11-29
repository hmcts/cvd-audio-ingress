moved {
  from = azurerm_lb.lb
  to   = azurerm_lb.cvp
}

moved {
  from = azurerm_lb_backend_address_pool.be_add_pool
  to   = azurerm_lb_backend_address_pool.wowza
}

moved {
  from = azurerm_lb_probe.lb_probe
  to   = azurerm_lb_probe.wowza["RTMPS"]
}

moved {
  from = azurerm_lb_rule.rtmps_lb_rule
  to   = azurerm_lb_rule.wowza["RTMPS"]
}

moved {
  from = azurerm_backup_policy_vm.vm_backup
  to   = azurerm_backup_policy_vm.vm_backup[0]
}

moved {
  from = azurerm_backup_policy_vm.vm_backup 
  to = azurerm_backup_policy_vm.vm_backup[0]
}