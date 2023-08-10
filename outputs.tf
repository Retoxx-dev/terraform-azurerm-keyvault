#################################################################
# KEY VUALT
#################################################################

output "key_vault_id" {
  value       = azurerm_key_vault.this.id
  description = "The ID of the Key Vault."
}

output "key_vault_name" {
  value       = azurerm_key_vault.this.name
  description = "The name of the Key Vault."
}

output "key_vault_location" {
  value       = azurerm_key_vault.this.location
  description = "The location of the Key Vault."
}

output "key_vault_uri" {
  value       = azurerm_key_vault.this.vault_uri
  description = "The URI of the Key Vault."
}

output "key_vault_tenant_id" {
  value       = azurerm_key_vault.this.tenant_id
  description = "The tenant ID of the Key Vault."
}

#################################################################
# PRIVATE ENDPOINT
#################################################################

output "private_endpoint_id" {
  value       = azurerm_private_endpoint.this[*].id
  description = "The ID of the Private Endpoint."
}

output "private_endpoint_network_interface" {
  value       = azurerm_private_endpoint.this[*].network_interface
  description = "The network interface of the Private Endpoint."
}

output "private_endpoint_custom_dns_configs" {
  value       = azurerm_private_endpoint.this[*].custom_dns_configs
  description = "The custom DNS configs of the Private Endpoint."
}

output "private_endpoint_ip_configuration" {
  value       = azurerm_private_endpoint.this[*].ip_configuration
  description = "The IP configuration of the Private Endpoint."
}

output "private_endpoint_private_dns_zone_configs" {
  value       = azurerm_private_endpoint.this[*].private_dns_zone_configs
  description = "The private DNS zone configs of the Private Endpoint."
}

#################################################################
# DIAGNOSTIC SETTINGS
#################################################################

output "diagnostic_setting_id" {
  value       = azurerm_monitor_diagnostic_setting.this[*].id
  description = "The ID of the Diagnostic Setting."
}