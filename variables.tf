variable "location" {
  type        = string
  description = "The azure resource location"
}

variable "env" {
  type        = string
  description = "The platform environment"
}

variable "environment" {
  type        = string
  description = "The platform environment. Used as tag value"
}

variable "builtFrom" {
  type        = string
  description = "Build pipeline"
}

variable "product" {
  type        = string
  description = "Product name used in naming standards"
}

variable "admin_ssh_key_path" {
  type    = string
  default = "~/.ssh/wowza.pub"
}

# DNS
variable "dns_zone_name" {
  type = string
}

variable "dns_resource_group" {
  type = string
}

variable "address_space" {
  type = string
}

variable "lb_IPaddress" {
  type = string
}

variable "cert_path" {
  type = string
}
variable "cert_name" {
  type = string
}

variable "wowza_publisher" {
  type = string
}

variable "wowza_offer" {
  type = string
}

variable "wowza_version" {
  type = string
}

variable "wowza_sku" {
  type    = string
  default = "linux-paid"
}

variable "num_applications" {
  type    = number
  default = 1
}


variable "rtmps_source_address_prefixes" {
  type = list(string)
}

variable "dev_source_address_prefixes" {
  type = string
}

variable "ws_name" {
  type = string
}

variable "ws_rg" {
  type    = string
  default = "oms-automation"
}

variable "ws_sub_id" {
  type = string
}

## Storage Account
variable "sa_recording_retention" {
  type        = number
  description = "How long to retain the recordings in blob"
}