#---------------------------------------------------
# General settings
#---------------------------------------------------
variable "location" {
  type        = string
  description = "(Required) The azure resource location."
  # From shared.tfvars
}

variable "env" {
  type        = string
  description = "(Required) The platform environment."
  # From <env>.tfvars
}

variable "environment" {
  type        = string
  description = "(Required) The platform environment. Used as tag value."
  # From <env>.tfvars
}

variable "builtFrom" {
  type        = string
  description = "(Required) Build pipeline."
  # Calculated by pipeline
}

variable "product" {
  type        = string
  description = "(Required) Product name used in naming standards."
  # From shared.tfvars
}

#---------------------------------------------------
# VM settings
#---------------------------------------------------
variable "vm_count" {
  type        = number
  description = "(Required) Number of Wowza VMS to create."
  # From <env>.tfvars
}

variable "vm_size" {
  type        = string
  default     = "Standard_D8ds_v5"
  description = "Size of VM. Defaults to \"Standard_F16s_v2\"."
  # From <env>.tfvars
}

variable "admin_ssh_key_path" {
  type        = string
  default     = "~/.ssh/wowza.pub"
  description = "Path to Wowza SSH key. Defaults to \"~/.ssh/wowza.pub\"."
}

variable "wowza_publisher" {
  type        = string
  default     = "wowza"
  description = "Publisher of VM image. Defaults to \"wowza\"."
}

variable "wowza_offer" {
  type        = string
  default     = "wowzastreamingengine"
  description = "Offer of the VM image. Defaults to \"wowzastreamingengine\"."
}

variable "wowza_version" {
  type        = string
  description = "(Required) Version of wowza VM image."
  # From shared.tfvars
}

variable "wowza_sku" {
  type        = string
  description = "(Required) SKU of wowza VM image."
  # From shared.tfvars
}

variable "admin_user" {
  type        = string
  default     = "wowza"
  description = "Admin username for wowza VM(s). Defaults to admin."
}

variable "os_disk_type" {
  type        = string
  default     = "Premium_LRS"
  description = "OS disk type for Wowza VM(s). Defaults to \"Premium_LRS\"."
}

variable "os_disk_size" {
  type        = number
  default     = 1024
  description = "OS disk size for Wowza VM(S). Defaults to 1024."
}

variable "cloud_init_file" {
  type        = string
  default     = "./cloudconfig/cloudconfig.tpl"
  description = "The location of the cloud init configuration file. Defaults to \"./cloudconfig.tpl\"."
}

variable "schedules" {
  type = list(object({
    name       = string
    frequency  = string
    interval   = number
    run_time   = string
    start_vm   = bool
    week_days  = optional(list(string))
    month_days = optional(list(number))
    monthly_occurrence = optional(object({
      day        = optional(string)
      occurrence = optional(number)
    }))
  }))
  default     = []
  description = "(Required) Start/Stop schedule for VM(s)."
}

variable "num_applications" {
  type        = number
  default     = 1
  description = "Number of Wowza applications to create as part of cloudinit, defaults to 1."
}

#---------------------------------------------------
# Networking settings
#---------------------------------------------------
variable "dns_zone_name" {
  type        = string
  description = "(Required) Private DNS zone name."
  # From <env>.tfvars
}

variable "dns_resource_group" {
  type        = string
  description = "(Required) Private DNS resource group name."
  # From <env>.tfvars
}

variable "address_space" {
  type        = string
  description = "(Required) VNET and subnet address space [CIDR]."
  # From <env>.tfvars

  validation {
    condition     = can(cidrhost(var.address_space, 0))
    error_message = "Must be valid IPv4 CIDR."
  }
}

variable "lb_IPaddress" {
  type        = string
  description = "(Required) frontend IP address to use for the internal load balancer."

  validation {
    condition     = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.lb_IPaddress))
    error_message = "Invalid IP address provided."
  }
}

variable "rtmps_source_address_prefixes" {
  type        = list(string)
  description = "(Required) Real-Time Messaging Protocol source IP addresses."
  # From <env>.tfvars
}

variable "f5_vpn_source_address_prefixes" {
  type        = list(string)
  description = "(Required) IP addresses of F5 VPN"
  default     = ["10.99.72.4"]
}

variable "globalconnect_vpn_source_address_prefixes" {
  type        = list(string)
  description = "(Required) IP addresses of GlobalConnect VPN"
  default     = ["128.77.75.64/26"]
}

variable "anyconnect_vpn_source_address_prefixes" {
  type        = list(string)
  description = "(Required) IP addresses of AnyConnect VPN"
  default = [
    "51.149.249.0/29",
    "51.149.249.32/29",
    "194.33.249.0/29",
    "194.33.248.0/29"
  ]
}

variable "dev_source_address_prefixes" {
  type = string
}

variable "route_table" {
  description = "Route Table routes"
  type        = list(map(string))
}

#---------------------------------------------------
# SAS 
#---------------------------------------------------

variable "expiry_days" {
  type        = number
  description = "Number of days that the SAS token should last. Default 30 days"
}

variable "remaining_days" {
  type        = number
  description = "Number of days remaining for which the SAS token should be renewed. Default 5 days"
}

#---------------------------------------------------
# Peering creds
#---------------------------------------------------
variable "network_client_id" {
  type        = string
  description = "(Required) Network peering client id"
}
variable "network_client_secret" {
  type        = string
  description = "(Required) Network peering client secret"
}
variable "network_tenant_id" {
  type        = string
  description = "(Required) Network peering tenant id"
}

#---------------------------------------------------
# Workspace settings
#---------------------------------------------------
variable "ws_name" {
  type        = string
  description = "(Required) Workspace Name."
  # From <env>.tfvars
}

variable "ws_rg" {
  type        = string
  description = "(Required) Workspace Resource Group."
  # From <env>.tfvars
}

variable "ws_sub_id" {
  type        = string
  description = "(Required) Workspace Subscription ID."
  # From az-shared-config.yml [log_analytics]
}

#---------------------------------------------------
# Storage Account settings
#---------------------------------------------------
variable "sa_access_tier" {
  type        = string
  default     = "Cool"
  description = "Defines the access tier for BlobStorage and StorageV2 accounts. Valid options are Hot and Cool, Defaults to Cool."

  validation {
    condition     = can(regex("^(Hot|Cool)$", var.sa_access_tier))
    error_message = "Invalid input, options: \"Hot\", \"Cool\"."
  }
}

variable "sa_account_kind" {
  type        = string
  default     = "BlobStorage"
  description = "Defines the Kind of account. Valid options are Storage, StorageV2 and BlobStorage. Changing this forces a new resource to be created. Defaults to BlobStorage."

  validation {
    condition     = can(regex("^(Storage|StorageV2|BlobStorage)$", var.sa_account_kind))
    error_message = "Invalid input, options: \"Storage\", \"StorageV2\", \"BlobStorage\"."
  }
}

variable "sa_account_tier" {
  type        = string
  default     = "Standard"
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium. Changing this forces a new resource to be created. Defaults to Standard."

  validation {
    condition     = can(regex("^(Standard|Premium)$", var.sa_account_tier))
    error_message = "Invalid input, options: \"Standard\", \"Premium\"."
  }
}

variable "sa_account_replication_type" {
  type        = string
  default     = "RAGRS"
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS and ZRS. Defaults to RAGRS."

  validation {
    condition     = can(regex("^(LRS|GRS|RAGRS|ZRS)$", var.sa_account_replication_type))
    error_message = "Invalid input, options: \"LRS\", \"GRS\", \"RAGRS\", \"ZRS\"."
  }
}

variable "sa_recording_retention" {
  type        = number
  description = "(Required) How long to retain the recordings in blob in days."
  default     = 90
}

variable "sa_allowed_subnets" {
  description = "Resource IDs of subnets to allow through storage firewall"
  type        = list(string)
  default     = null
}

variable "sa_allowed_ips" {
  type        = list(string)
  description = "(Optional) List of public IP addresses which will have access to storage account."
  default     = []
}

variable "sa_default_action" {
  type        = string
  default     = "Deny"
  description = "What is the default action of the networking for the storage account. Defaults to 'Deny'"
}

variable "delete_after_days_since_creation_greater_than" {
  type        = number
  default     = 90
  description = "Number of days to keep an ingest file for before deleting it. Default 90 days"
}

variable "sa_policy_enabled" {
  type        = bool
  default     = true
  description = "Status of the storage account lifecycle policy. Default 'true'"
}

variable "retention_period" {
  type        = number
  default     = 365
  description = "(Optional) Specifies the number of days that the blob should be retained, between 1 and 365 days. Defaults to 365"
}

#---------------------------------------------------
# Automation Account settings
#---------------------------------------------------

variable "automation_account_sku_name" {
  type        = string
  description = "Azure Automation Account SKU name."
  default     = "Basic"
  validation {
    condition     = contains(["Basic"], var.automation_account_sku_name)
    error_message = "Azure Automation Account SKUs are limited to Basic."
  }
}

#---------------------------------------------------
# Dynatrace settings
#---------------------------------------------------

variable "dynatrace_tenant" {
  type        = string
  description = "Name Given To Dynatrace Tenant."
}
