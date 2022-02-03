locals {
  service_name      = "${var.product}-recordings-${var.env}"
  vms               = ["vm1", "vm2"]
  domain_dns_prefix = var.env == "stg" ? "aat" : var.env == "sbox" ? "sandbox" : var.env == "stg" ? "staging" : var.env
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.service_name}-rg"
  location = var.location
  tags     = var.common_tags
}

resource "azurerm_virtual_network" "vnet" {
  name          = "${local.service_name}-vnet"
  address_space = [var.address_space]

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = var.common_tags
}

resource "azurerm_subnet" "sn" {
  name                 = "wowza"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.address_space]
  service_endpoints    = ["Microsoft.KeyVault"]

  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_private_endpoint" "endpoint" {
  name = "${module.sa.storageaccount_name}-endpoint"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  subnet_id = azurerm_subnet.sn.id

  private_service_connection {
    name                           = "${module.sa.storageaccount_name}-scon"
    private_connection_resource_id = module.sa.storageaccount_id
    subresource_names              = ["Blob"]
    is_manual_connection           = false
  }
  tags = var.common_tags
}

data "azurerm_private_dns_zone" "blob" {
  provider = azurerm.shared-dns-zone

  name                = "privatelink.blob.core.windows.net"
  resource_group_name = "core-infra-intsvc-rg"
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  provider = azurerm.shared-dns-zone
  
  name                  = "${azurerm_virtual_network.vnet.name}-link"
  resource_group_name   = "core-infra-intsvc-rg"
  private_dns_zone_name = data.azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = true
  tags                  = var.common_tags
}

resource "azurerm_private_dns_a_record" "sa_a_record" {
  provider = azurerm.shared-dns-zone
  
  name                = module.sa.storageaccount_name
  zone_name           = data.azurerm_private_dns_zone.blob.name
  resource_group_name = "core-infra-intsvc-rg"
  ttl                 = 300
  records             = [azurerm_private_endpoint.endpoint.private_service_connection.0.private_ip_address]
  tags                = var.common_tags
}

#tfsec:ignore:azure-network-ssh-blocked-from-internet
resource "azurerm_network_security_group" "sg" {
  name = "${local.service_name}-sg"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  #ingress rules
  security_rule {
    name                       = "RTMPS"
    priority                   = 1040
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = var.rtmps_source_address_prefixes
    destination_address_prefix = "*"
  }

  #egress rules
  security_rule {
    name                       = "Required_Packages_443"
    priority                   = 1041
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
  security_rule {
    name                       = "Required_Packages_80"
    priority                   = 1042
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
  security_rule {
    name                       = "DNS_53"
    priority                   = 1043
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
  security_rule {
    name                       = "Sftp"
    priority                   = 1044
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
  security_rule {
    name                       = "VNet"
    priority                   = 1045
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name                       = "Deny_All"
    priority                   = 4096
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = var.common_tags
}

resource "azurerm_public_ip" "pip_vm1" {
  name = "${local.service_name}-pipvm1"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  allocation_method = "Static"
  sku               = "Standard"
  tags              = var.common_tags
}
resource "azurerm_network_interface" "nic1" {
  name = "${local.service_name}-nic1"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "wowzaConfiguration"
    subnet_id                     = azurerm_subnet.sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip_vm1.id
  }
  tags = var.common_tags
}
resource "azurerm_public_ip" "pip_vm2" {
  name = "${local.service_name}-pipvm2"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  allocation_method = "Static"
  sku               = "Standard"
  tags              = var.common_tags
}
resource "azurerm_network_interface" "nic2" {
  name = "${local.service_name}-nic2"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "wowzaConfiguration"
    subnet_id                     = azurerm_subnet.sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip_vm2.id
  }
  tags = var.common_tags
}


resource "azurerm_network_interface_security_group_association" "sg_assoc1" {
  network_interface_id      = azurerm_network_interface.nic1.id
  network_security_group_id = azurerm_network_security_group.sg.id
}

resource "azurerm_network_interface_security_group_association" "sg_assoc2" {
  network_interface_id      = azurerm_network_interface.nic2.id
  network_security_group_id = azurerm_network_security_group.sg.id
}

resource "azurerm_subnet_network_security_group_association" "sg_assoc_subnet" {
  subnet_id                 = azurerm_subnet.sn.id
  network_security_group_id = azurerm_network_security_group.sg.id
}

resource "azurerm_network_interface_backend_address_pool_association" "be_add_pool_assoc_vm1" {
  network_interface_id    = azurerm_network_interface.nic1.id
  ip_configuration_name   = azurerm_network_interface.nic1.ip_configuration.0.name
  backend_address_pool_id = azurerm_lb_backend_address_pool.be_add_pool.id
}

resource "azurerm_network_interface_backend_address_pool_association" "be_add_pool_assoc_vm2" {
  network_interface_id    = azurerm_network_interface.nic2.id
  ip_configuration_name   = azurerm_network_interface.nic2.ip_configuration.0.name
  backend_address_pool_id = azurerm_lb_backend_address_pool.be_add_pool.id
}

resource "random_password" "certPassword" {
  length           = 32
  special          = true
  override_special = "_%*"
}

resource "random_password" "restPassword" {
  length           = 32
  special          = true
  override_special = "_%*"
}

resource "random_password" "streamPassword" {
  length           = 32
  special          = true
  override_special = "_%*"
}

data "template_file" "cloudconfig" {
  template = file(var.cloud_init_file)
  vars = {
    certPassword            = random_password.certPassword.result
    storageAccountName      = module.sa.storageaccount_name
    storageAccountKey       = module.sa.storageaccount_primary_access_key
    restPassword            = md5("wowza:Wowza:${random_password.restPassword.result}")
    streamPassword          = md5("wowza:Wowza:${random_password.streamPassword.result}")
    containerName           = local.main_container_name
    logsContainerName       = local.wowza_logs_container_name
    numApplications         = var.num_applications
    managedIdentityClientId = azurerm_user_assigned_identity.mi.client_id
    certName                = "cvp-${var.env}-le-cert"
    keyVaultName            = "cvp-${var.env}-kv"
    domain                  = "cvp-recording.${local.domain_dns_prefix}.platform.hmcts.net"
    wowzaVersion            = var.wowza_version
  }
}

data "template_cloudinit_config" "wowza_setup" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.cloudconfig.rendered
  }
}
data "azurerm_key_vault" "cvp_kv" {
  name                = "cvp-${var.env}-kv"
  resource_group_name = "cvp-sharedinfra-${var.env}"
}
data "azurerm_client_config" "current" {
}
data "azurerm_key_vault_secret" "ssh_pub_key" {
  name         = "cvp-ssh-pub-key"
  key_vault_id = data.azurerm_key_vault.cvp_kv.id
}

resource "azurerm_linux_virtual_machine" "vm1" {
  name = "${local.service_name}-vm1"

  depends_on = [
    azurerm_private_dns_a_record.sa_a_record,
    azurerm_private_dns_zone_virtual_network_link.vnet_link
  ]

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  size           = var.vm_size
  admin_username = var.admin_user
  network_interface_ids = [
    azurerm_network_interface.nic1.id,
  ]

  admin_ssh_key {
    username   = var.admin_user
    public_key = data.azurerm_key_vault_secret.ssh_pub_key.value
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size
  }

  provision_vm_agent = true

  custom_data = data.template_cloudinit_config.wowza_setup.rendered

  source_image_reference {
    publisher = var.wowza_publisher
    offer     = var.wowza_offer
    sku       = var.wowza_sku
    version   = var.wowza_version
  }

  plan {
    name      = var.wowza_sku
    product   = var.wowza_offer
    publisher = var.wowza_publisher
  }

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.mi.id]
  }
  tags = var.common_tags
}

resource "azurerm_linux_virtual_machine" "vm2" {
  name = "${local.service_name}-vm2"

  depends_on = [
    azurerm_private_dns_a_record.sa_a_record,
    azurerm_private_dns_zone_virtual_network_link.vnet_link
  ]

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  size           = var.vm_size
  admin_username = var.admin_user
  network_interface_ids = [
    azurerm_network_interface.nic2.id,
  ]

  admin_ssh_key {
    username   = var.admin_user
    public_key = data.azurerm_key_vault_secret.ssh_pub_key.value
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size
  }

  provision_vm_agent = true

  custom_data = data.template_cloudinit_config.wowza_setup.rendered

  source_image_reference {
    publisher = var.wowza_publisher
    offer     = var.wowza_offer
    sku       = var.wowza_sku
    version   = var.wowza_version
  }

  plan {
    name      = var.wowza_sku
    product   = var.wowza_offer
    publisher = var.wowza_publisher
  }

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.mi.id]
  }
  tags = var.common_tags
}

data "azurerm_log_analytics_workspace" "log_analytics" {
  name                = var.ws_name
  resource_group_name = var.ws_rg
  provider            = azurerm.secops
}
