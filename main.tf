locals {
  rg_name      = "${var.product}-media-service-${var.env}"
  sa_name      = "${var.product}mediaservice${var.env}"
  service_name = "${var.product}mediaservice${var.env}"
  common_tags  = module.ctags.common_tags
}

module "ctags" {
  source      = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=master"
  environment = var.env
  product     = var.product
  builtFrom   = var.builtFrom
}

module "wowza" {
  source                        = "./modules/wowza"
  location                      = var.location
  product                       = var.product
  env                           = var.env
  common_tags                   = local.common_tags
  admin_ssh_key_path            = var.admin_ssh_key_path
  address_space                 = var.address_space
  lb_IPaddress                  = var.lb_IPaddress
  num_applications              = var.num_applications
  cert_path                     = var.cert_path
  cert_name                     = var.cert_name
  wowza_sku                     = var.wowza_sku
  wowza_version                 = var.wowza_version
  wowza_publisher               = var.wowza_publisher
  wowza_offer                   = var.wowza_offer
  rtmps_source_address_prefixes = var.rtmps_source_address_prefixes
  dev_source_address_prefixes   = var.dev_source_address_prefixes
  ws_name                       = var.ws_name
  ws_sub_id                     = var.ws_sub_id
  ws_rg                         = var.ws_rg
  sa_recording_retention        = var.sa_recording_retention
}

resource "azurerm_dns_a_record" "wowza" {
  name                = "${var.product}-media-service-${var.env}"
  zone_name           = var.dns_zone_name
  resource_group_name = var.dns_resource_group
  ttl                 = 300
  records             = [var.lb_IPaddress]
  tags                = local.common_tags
}