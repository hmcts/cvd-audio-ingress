locals {
  service_name  = "${var.product}-recordings-${var.env}"
  wowza_sku     = "linux-paid"
  wowza_version = "4.7.7"
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.service_name}-rg"
  location = var.location
  tags     = var.common_tags
}

resource "azurerm_storage_account" "sa" {
  name                = "${replace(lower(local.service_name), "-", "")}sa2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = var.common_tags
  access_tier               = var.sa_access_tier
  account_kind              = var.sa_account_kind
  account_tier              = var.sa_account_tier
  account_replication_type  = var.sa_account_replication_type
  enable_https_traffic_only = true
}

resource "azurerm_storage_container" "media_container" {
  name                  = "recordings"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

resource "azurerm_virtual_network" "vnet" {
  name          = "${local.service_name}-vnet"
  address_space = [var.address_space]

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_subnet" "sn" {
  name                 = "wowza"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = var.address_space

  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_private_endpoint" "endpoint" {
  name = "${azurerm_storage_account.sa.name}-endpoint"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  subnet_id = azurerm_subnet.sn.id

  private_service_connection {
    name                           = "${azurerm_storage_account.sa.name}-scon"
    private_connection_resource_id = azurerm_storage_account.sa.id
    subresource_names              = ["Blob"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  name                  = "${azurerm_virtual_network.vnet.name}-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = true
}

resource "azurerm_private_dns_a_record" "sa_a_record" {
  name                = azurerm_storage_account.sa.name
  zone_name           = azurerm_private_dns_zone.blob.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.endpoint.private_service_connection.0.private_ip_address]
}

# resource "azurerm_storage_account_network_rules" "wowza" {
#   resource_group_name  = azurerm_resource_group.rg.name
#   storage_account_name = azurerm_storage_account.sa.name

#   default_action             = "Deny"
#   ip_rules                   = []
#   virtual_network_subnet_ids = []
#   bypass                     = ["Logging", "AzureServices"]
# }

resource "azurerm_public_ip" "pip" {
  name = "${local.service_name}-pip"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  allocation_method = "Static"
}

resource "azurerm_network_security_group" "sg" {
  name = "${local.service_name}-sg"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  security_rule {
    name                       = "Server"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1935"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "RTSP"
    priority                   = 1020
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "554"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "REST"
    priority                   = 1030
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8087"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AdminUI"
    priority                   = 1040
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8088"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1050
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 1060
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  name = "${local.service_name}-nic"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "wowzaConfiguration"
    subnet_id                     = azurerm_subnet.sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "sg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.sg.id
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
    certPassword       = random_password.certPassword.result
    certThumbprint     = var.thumbprint
    storageAccountName = azurerm_storage_account.sa.name
    storageAccountKey  = azurerm_storage_account.sa.primary_access_key
    restPassword       = md5("wowza:Wowza:${random_password.restPassword.result}")
    streamPassword     = md5("wowza:Wowza:${random_password.streamPassword.result}")
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

resource "tls_private_key" "tf_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "vm" {
  name = "${local.service_name}-vm"

  depends_on = [
    azurerm_private_dns_a_record.sa_a_record,
    azurerm_private_dns_zone_virtual_network_link.vnet_link
  ]

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  size           = var.vm_size
  admin_username = var.admin_user
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_ssh_key {
    username   = var.admin_user
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDc8ujPUBBo2fG8QrDHFHamZ6AOeTOVP7lmQ95hWufzAy03MbMufshkp2xkpBYrm9WQf9mDWqqDa5rBF7LoqJT7vRKuDbn04B/puwIHnVEVb9ROGXJ61tUURIsrQ5H4PtdluVrNpqJT/vFZBbat2ewrq8idXGGrHlcZovGpm0GOBvnDLAEfP3MXb5FqgWWikpsIMaJMF79fvw1W59uC5Wlo7HaKaAIk6Klp5EFM1TKDHj8I9cAc8XHilM3/JvjG2gCm4JMxMnIS7pRBISgSlZK16ALteaQTkO7OgkmaANqT2t1l64vCpxtRyccpvFnIKvseiRwXXFuLjFjy238b7eOU6Ktfb4RHaOIRvt/EEi9GXnrMSjEBgx5PKiCKuwFhpH6EL0I0B/CCb9h8k19ZA0FIGhH/ZHFJ2WdAIzKYbjXDCNHOejs4B+UUqcY6e/s9C4dLap+fCpXKRSwsRG0inRkttAcuyPu1ewtOE/qeSl5DN2fqKV6r0Gm4lQfdHUMTrcU="
  }

  admin_ssh_key {
    username   = var.admin_user
    public_key = tls_private_key.tf_ssh_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
  }

  provision_vm_agent = true
  secret {
    certificate {
      url = var.service_certificate_kv_url
    }
    key_vault_id = var.key_vault_id
  }

  custom_data = data.template_cloudinit_config.wowza_setup.rendered

  source_image_reference {
    publisher = "wowza"
    offer     = "wowzastreamingengine"
    sku       = local.wowza_sku
    version   = local.wowza_version
  }

  plan {
    name      = local.wowza_sku
    product   = "wowzastreamingengine"
    publisher = "wowza"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "null_resource" "cert" {

  depends_on = [
    azurerm_linux_virtual_machine.vm
  ]

  triggers = {
    vm = azurerm_linux_virtual_machine.vm.id
  }

  provisioner "file" {
    content = file("modules/wowza/wowza-applications/GandiStandardSSLCA2.pem")
    destination = "/home/wowza/GandiStandardSSLCA2.pem"

    connection {
      type = "ssh"
      user = var.admin_user
      private_key = tls_private_key.tf_ssh_key.private_key_pem
      host = azurerm_public_ip.pip.ip_address
      port = "22"
      timeout = "1m"
    }
  }

  provisioner "remote-exec" {

    connection {
      type        = "ssh"
      user        = var.admin_user
      private_key = tls_private_key.tf_ssh_key.private_key_pem
      host        = azurerm_public_ip.pip.ip_address
      port        = "22"
      timeout     = "1m"
    }

    inline = [
      "sudo chown root: /home/wowza/GandiStandardSSLCA2.pem",
      "sudo chmod 777 /home/wowza/GandiStandardSSLCA2.pem",
      "sudo cp -uv /home/wowza/GandiStandardSSLCA2.pem /etc/ssl/GandiStandardSSLCA2.pem",
      "sudo c_rehash",
      "sudo cp /home/wowza/GandiStandardSSLCA2.pem /usr/local/share/ca-certificates/GandiStandardSSLCA2.pem",
      "sudo cp /home/wowza/GandiStandardSSLCA2.pem /usr/lib/ssl/certs/GandiStandardSSLCA2.pem",
      "sudo update-ca-certificates"
    ]
  }
}

resource "null_resource" "wowza_applications" {

  depends_on = [
    azurerm_linux_virtual_machine.vm
  ]

  triggers = {
    num_applications = var.num_applications
    vm = azurerm_linux_virtual_machine.vm.id
  }

  provisioner "file" {
    content     = file("modules/wowza/wowza-applications/dir-creator.sh")
    destination = "/home/wowza/dir-creator.sh"

    connection {
      type        = "ssh"
      user        = var.admin_user
      private_key = tls_private_key.tf_ssh_key.private_key_pem
      host        = azurerm_public_ip.pip.ip_address
      port        = "22"
      timeout     = "1m"
    }
  }

  provisioner "file" {
    content     = file("modules/wowza/wowza-applications/Application.xml")
    destination = "/home/wowza/Application.xml"

    connection {
      type        = "ssh"
      user        = var.admin_user
      private_key = tls_private_key.tf_ssh_key.private_key_pem
      host        = azurerm_public_ip.pip.ip_address
      port        = "22"
      timeout     = "1m"
    }
  }

  provisioner "remote-exec" {

    connection {
      type        = "ssh"
      user        = var.admin_user
      private_key = tls_private_key.tf_ssh_key.private_key_pem
      host        = azurerm_public_ip.pip.ip_address
      port        = "22"
      timeout     = "1m"
    }

    inline = [
      "chmod 775 ./dir-creator.sh",
      "./dir-creator.sh ${var.num_applications}",
      "sudo service WowzaStreamingEngine stop",
      "sudo service WowzaStreamingEngine start"
    ]
  }
}
