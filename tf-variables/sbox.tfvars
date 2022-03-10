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
auto_acc_runbooks = [
  {
    name       = "vm-on",
    frequency  = "Day"
    interval   = 1
    run_time = "06:00:00"
    start_vm   = true
  },
  {
    name       = "vm-off",
    frequency  = "Day"
    interval   = 1
    run_time = "20:00:00"
    start_vm   = false
  }
]