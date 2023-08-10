#################################################################
# DATAS
#################################################################

data "azurerm_client_config" "current" {}

data "azuread_group" "this" {
  count        = length(local.azure_ad_group_names)
  display_name = local.azure_ad_group_names[count.index]
}

data "azuread_user" "this" {
  count = length(local.azure_ad_user_upns)
  user_principal_name =   local.azure_ad_user_upns[count.index]
}

data "azuread_service_principal" "this" {
  count        = length(local.azure_ad_service_principal_names)
  display_name = local.azure_ad_service_principal_names[count.index]
}

#################################################################
# AZURE KEY VAULT
#################################################################

resource "azurerm_key_vault" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name  = var.sku_name
  tenant_id = data.azurerm_client_config.current.tenant_id

  dynamic "access_policy" {
    for_each = local.combined_access_policies
    content {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      object_id               = access_policy.value.object_id
      certificate_permissions = access_policy.value.certificate_permissions
      key_permissions         = access_policy.value.key_permissions
      secret_permissions      = access_policy.value.secret_permissions
      storage_permissions     = access_policy.value.storage_permissions
    }
  }

  dynamic "access_policy" {
    for_each = [local.self_permissions]
    content {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      object_id               = access_policy.value.object_id
      certificate_permissions = access_policy.value.certificate_permissions
      key_permissions         = access_policy.value.key_permissions
      secret_permissions      = access_policy.value.secret_permissions
      storage_permissions     = access_policy.value.storage_permissions
    }
  }

  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  enable_rbac_authorization       = var.enable_rbac_authorization

  dynamic "network_acls" {
    for_each = var.network_acls != null ? [true] : []
    content {
      bypass                     = var.network_acls.bypass
      default_action             = var.network_acls.default_action
      ip_rules                   = var.network_acls.ip_rules
      virtual_network_subnet_ids = var.network_acls.virtual_network_subnet_ids
    }
  }

  purge_protection_enabled      = var.purge_protection_enabled
  public_network_access_enabled = var.public_network_access_enabled
  soft_delete_retention_days    = var.soft_delete_retention_days

  tags = var.tags
}

#################################################################
# AZURE KEY VAULT - PRIVATE ENDPOINT
#################################################################

resource "azurerm_private_endpoint" "this" {
  count                         = var.private_endpoint != null ? 1 : 0
  name                          = var.private_endpoint.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  subnet_id                     = var.private_endpoint.subnet_id
  custom_network_interface_name = var.private_endpoint.custom_network_interface_name

  private_dns_zone_group {
    name                 = "privatelink.vaultcore.azure.net"
    private_dns_zone_ids = [var.private_endpoint.private_dns_zone_id]
  }

  private_service_connection {
    name                           = "${var.private_endpoint.name}-privatelink"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
  }

  tags = merge(
    var.tags, var.private_endpoint.tags
  )
}

#################################################################
# AZURE KEY VAULT - DIAGNOTIC SETTINGS
#################################################################

resource "azurerm_monitor_diagnostic_setting" "this" {
  count                      = var.diagnostic_settings != null ? 1 : 0
  name                       = var.diagnostic_settings.name
  target_resource_id         = azurerm_key_vault.this.id
  log_analytics_workspace_id = var.diagnostic_settings.log_analytics_workspace_id
  storage_account_id         = var.diagnostic_settings.storage_account_id

  log_analytics_destination_type = var.diagnostic_settings.log_analytics_destination_type

  dynamic "enabled_log" {
    for_each = var.diagnostic_settings.diag_logs
    content {
      category = enabled_log.value.category

      retention_policy {
        enabled = enabled_log.value.retention_policy_enabled
        days    = enabled_log.value.retention_policy_days
      }
    }
  }

  dynamic "metric" {
    for_each = var.diagnostic_settings.diag_metrics
    content {
      category = metric.value.category

      retention_policy {
        enabled = metric.value.retention_policy_enabled
        days    = metric.value.retention_policy_days
      }
    }
  }

  lifecycle {
    ignore_changes = [
      log_analytics_destination_type
    ]
  }
}