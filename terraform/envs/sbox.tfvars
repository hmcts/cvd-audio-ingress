environment                   = "sbox"
env                           = "sbox"
vm_count                      = 1
dns_zone_name                 = "shared-services.uk.south.sbox.hmcts.internal"
dns_resource_group            = "cvp-sharedinfra-sbox"
address_space                 = "10.50.11.0/28"
lb_IPaddress                  = "10.50.11.10"
rtmps_source_address_prefixes = ["35.204.50.163", "35.204.108.36", "34.91.92.40", "34.91.75.226", "81.109.71.47"]
ws_name                       = "hmcts-sandbox"
ws_rg                         = "oms-automation"
num_applications              = 20
vm_size                       = "Standard_D4ds_v5"
os_disk_type                  = "StandardSSD_LRS"
os_disk_size                  = "512"
dynatrace_tenant              = "yrk32651"
expiry_days                   = 3
remaining_days                = 1
retention_period              = 7
schedules = [
  {
    name      = "vm-off",
    frequency = "Day"
    interval  = 1
    run_time  = "18:00:00"
    start_vm  = false
  },
]
route_table = [
  {
    name                   = "default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.200.36"
  },
  {
    name                   = "azure_control_plane"
    address_prefix         = "51.145.56.125/32"
    next_hop_type          = "Internet"
    next_hop_in_ip_address = null
  }
]
sa_allowed_subnets = [
  # "/subscriptions/b72ab7b7-723f-4b18-b6f6-03b0f2c6a1bb/resourceGroups/cft-sbox-network-rg/providers/Microsoft.Network/virtualNetworks/cft-sbox-vnet/subnets/aks-00",
  # "/subscriptions/b72ab7b7-723f-4b18-b6f6-03b0f2c6a1bb/resourceGroups/cft-sbox-network-rg/providers/Microsoft.Network/virtualNetworks/cft-sbox-vnet/subnets/aks-01"
]

sa_allowed_ips = [
  "128.77.75.64/26",  #GlobalProtect VPN egress range
  "51.149.249.0/29",  #AnyConnect VPN egress range
  "51.149.249.32/29", #AnyConnect VPN egress range
  "194.33.249.0/29",  #AnyConnect VPN egress backup range
  "194.33.248.0/29"   #AnyConnect VPN egress backup range
]

hrs_aks_source_address_prefixes = [
  "10.50.64.0/20", # cft-demo-vnet aks-00
  "10.50.80.0/20"  # cft-demo-vnet aks-01
]