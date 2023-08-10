#################################################################
# GENERAL
#################################################################

variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which to create the Kubernetes Cluster."
}

variable "location" {
  type        = string
  description = "(Required) The location in which to create the Kubernetes Cluster."
}

#################################################################
# KEY VAULT
#################################################################

variable "name" {
  type        = string
  description = "(Required) Specifies the name of the Key Vault. Changing this forces a new resource to be created. The name must be globally unique. If the vault is in a recoverable state then the vault will need to be purged before reusing the name."
}

variable "sku_name" {
  type        = string
  description = "(Required) The Name of the SKU used for this Key Vault. Possible values are `standard` and `premium`."
  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "sku_name must be either `standard` or `premium`"
  }
}

variable "access_policies" {
  type        = list(any)
  description = "(Optional) List of access policies for the Key Vault."
  default     = []
}

variable "enabled_for_deployment" {
  type        = bool
  description = "(Optional) Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault."
  default     = null
}

variable "enabled_for_disk_encryption" {
  type        = bool
  description = "(Optional) Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys."
  default     = null
}

variable "enabled_for_template_deployment" {
  type        = bool
  description = "(Optional) Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault."
  default     = null
}

variable "enable_rbac_authorization" {
  type        = bool
  description = "(Optional) Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions."
  default     = null
}

variable "network_acls" {
  type = object({
    bypass                     = string
    default_action             = string
    ip_rules                   = optional(list(string))
    virtual_network_subnet_ids = optional(list(string))
  })
  description = "(Optional) A network_acls block that supports: `bypass`, `default_action`, `(optional) ip_rules`, `(optional) virtual_network_subnet_ids` fields"
  default     = null
}

variable "purge_protection_enabled" {
  type        = bool
  description = "(Optional) Is Purge Protection enabled for this Key Vault?"
  default     = null
}

variable "public_network_access_enabled" {
  type        = bool
  description = "(Optional) Whether public network access is allowed for this Key Vault. Defaults to true."
  default     = true
}

variable "soft_delete_retention_days" {
  type        = number
  description = "(Optional) The number of days that items should be retained for once soft-deleted. This value can be between 7 and 90 (the default) days."
  default     = 90
  validation {
    condition = (
      var.soft_delete_retention_days >= 7 &&
      var.soft_delete_retention_days <= 90
    )
    error_message = "soft_delete_retention_days must be between 7 and 90, inclusive."
  }
}

variable "self_service_principal_id" {
  type        = string
  description = "(Optional) ID of the service principal that shall have all access in the Key Vault"
  default     = ""
  validation {
    condition     = (can(regex("^[0-9A-Za-z]{8}-[0-9A-Za-z]{4}-[0-9A-Za-z]{4}-[0-9A-Za-z]{4}-[0-9A-Za-z]{12}$", var.self_service_principal_id)))
    error_message = "self_service_principal_id must be in XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX form"
  }
}

variable "tags" {
  type        = map(string)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}

#################################################################
# AZURE KEY VAULT - PRIVATE ENDPOINT
#################################################################

variable "private_endpoint" {
  type = object({
    name                          = string
    subnet_id                     = string
    custom_network_interface_name = optional(string, null)
    tags                          = optional(map(string))

    private_dns_zone_id   = string
  })
  description = "(Optional) Enable private endpoint for the key vault"
  default     = null
}

#################################################################
# LOGS
#################################################################
variable "diagnostic_settings" {
  type = object({
    name                           = string
    storage_account_id             = optional(string, null)
    log_analytics_destination_type = string
    log_analytics_workspace_id     = optional(string, null)

    diag_logs = optional(list(object({
      category                 = string
      retention_policy_enabled = bool
      retention_policy_days    = number
    })), [])

    diag_metrics = list(object({
      category                 = string
      retention_policy_enabled = bool
      retention_policy_days    = number
    }))
  })
  description = "(Optional) Configuration of monitor diagnostic setting"
  default     = null
}