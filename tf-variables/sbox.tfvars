environment                   = "sbox"
env                           = "sbox"
dns_zone_name                 = "shared-services.uk.south.sbox.hmcts.internal"
dns_resource_group            = "cvp-sharedinfra-sbox"
address_space                 = "10.50.11.0/28"
lb_IPaddress                  = "10.50.11.10"
rtmps_source_address_prefixes = ["35.204.50.163", "35.204.108.36", "34.91.92.40", "34.91.75.226", "81.109.71.47"]
ws_name                       = "hmcts-sandbox"
ws_rg                         = "oms-automation"
num_applications              = 20
script_name                   = "vm_automation/vm-start-stop.ps1"
vm_status = {
  "vm_resting_state_on"           = false
  "azdo_pipe_to_change_vm_status" = true
}
runbook_schedule_times = {
  "frequency" = "Day"
  "interval"  = 1
  "timezone"  = "Europe/London"
  # "start_time" = "2022-03-01T16:00:00Z"
}