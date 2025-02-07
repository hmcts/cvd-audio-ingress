module "nsg" {
  source = "git::https://github.com/hmcts/terraform-module-network-security-group.git?ref=v1.0.0"

  network_security_group_name = "${local.service_name}-nsg"
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location

  subnet_ids = {
    "${azurerm_subnet.sn.name}" = azurerm_subnet.sn.id
  }

  tags = module.ctags.common_tags

  custom_rules = [
    {
      access                       = "Allow"
      description                  = "Allow SSH from F5 VPN"
      destination_address_prefixes = azurerm_network_interface.wowza_nic.*.private_ip_address
      destination_port_range       = "22"
      direction                    = "Inbound"
      name                         = "Allow_F5_VPN_SSH"
      priority                     = 1100
      protocol                     = "Tcp"
      source_address_prefixes      = var.f5_vpn_source_address_prefixes
      source_port_range            = "*"
    },
    {
      access                       = "Allow"
      description                  = "Allow Wowza RTMPS"
      destination_address_prefixes = azurerm_network_interface.wowza_nic.*.private_ip_address
      destination_port_ranges      = ["443", "444", "445"]
      direction                    = "Inbound"
      name                         = "Allow_RTMPS"
      priority                     = 1200
      protocol                     = "Tcp"
      source_address_prefixes      = concat(var.f5_vpn_source_address_prefixes, var.globalconnect_vpn_source_address_prefixes, var.anyconnect_vpn_source_address_prefixes, var.rtmps_source_address_prefixes)
      source_port_range            = "*"
    },
    {
      access                       = "Allow"
      description                  = "Allow access to Wowza SE Manager"
      destination_address_prefixes = azurerm_network_interface.wowza_nic.*.private_ip_address
      destination_port_ranges      = ["8090", "8091", "8092"]
      direction                    = "Inbound"
      name                         = "Allow_WSEM"
      priority                     = 1300
      protocol                     = "Tcp"
      source_address_prefixes      = concat(var.f5_vpn_source_address_prefixes, var.globalconnect_vpn_source_address_prefixes, var.anyconnect_vpn_source_address_prefixes)
      source_port_range            = "*"
    },
    {
      access                       = "Allow"
      description                  = "Allow access to Wowza API"
      destination_address_prefixes = azurerm_network_interface.wowza_nic.*.private_ip_address
      destination_port_ranges      = ["8087", "8088", "8089"]
      direction                    = "Inbound"
      name                         = "Allow_WSE_API"
      priority                     = 1400
      protocol                     = "Tcp"
      source_address_prefixes      = concat(var.f5_vpn_source_address_prefixes, var.globalconnect_vpn_source_address_prefixes, var.anyconnect_vpn_source_address_prefixes, var.rtmps_source_address_prefixes)
      source_port_range            = "*"
    },
    {
      access                     = "Allow"
      description                = "Allow LB probes"
      destination_address_prefix = "*"
      destination_port_ranges    = ["8087", "8090", "443"]
      direction                  = "Inbound"
      name                       = "Allow_LB"
      priority                   = 1500
      protocol                   = "Tcp"
      source_address_prefix      = "AzureLoadBalancer"
      source_port_range          = "*"
    },
    {
      access                       = "Allow"
      description                  = "Allow SSH from GlobalConnect VPN"
      destination_address_prefixes = azurerm_network_interface.wowza_nic.*.private_ip_address
      destination_port_range       = "22"
      direction                    = "Inbound"
      name                         = "Allow_GlobalConnect_VPN_SSH"
      priority                     = 1600
      protocol                     = "Tcp"
      source_address_prefixes      = var.globalconnect_vpn_source_address_prefixes
      source_port_range            = "*"
    },
    {
      access                       = "Allow"
      description                  = "Allow SSH from AnyConnect VPN"
      destination_address_prefixes = azurerm_network_interface.wowza_nic.*.private_ip_address
      destination_port_range       = "22"
      direction                    = "Inbound"
      name                         = "Allow_AnyConnect_VPN_SSH"
      priority                     = 1700
      protocol                     = "Tcp"
      source_address_prefixes      = var.anyconnect_vpn_source_address_prefixes
      source_port_range            = "*"
    }
  ]
}
