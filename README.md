# terraform-azurerm-keyvault
Terraform module for Azure Key Vault

Azure Key Vault is a cloud-based service provided by Microsoft Azure that enables you to securely store and manage cryptographic keys, secrets, and certificates.

Using Azure Key Vault, you can protect your sensitive application data and maintain control over access to your data by storing it in a central location that's highly available, scalable, and durable. Key Vault is designed to simplify key management and streamline access to your cryptographic keys and secrets, which can be used by your applications and services in Azure or outside of Azure.

This module creates:
- Key Vault
- Private Endpoint (optional)
- Diagnostic Settings (optional)

This module WON'T create:
- Resource Group
- Storage Account
- Log Analytics Workspace
- Virtual Network with Subnets
- Private DNS Zone and Virtual Network Link

It is higly recommended to specify `self_service_principal_id` as without it, local deployment with your AZURE account might be awful. What it does basically is that it creates a access policy for your service principal to access the Key Vault.

In access policies you can specify either `azure_ad_user_upns`, `azure_ad_group_names`, `azure_ad_service_principal_names` or all of them. For the permissions, you can use: `secret_permissions`, `certificate_permissions` and `storage_permissions`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.1 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >=2.41 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.65 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | >=2.41 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=3.65 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azuread_group.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azuread_service_principal.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |
| [azuread_user.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/user) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_policies"></a> [access\_policies](#input\_access\_policies) | (Optional) List of access policies for the Key Vault. | `list(any)` | `[]` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | (Optional) Configuration of monitor diagnostic setting | <pre>object({<br>    name                           = string<br>    storage_account_id             = optional(string, null)<br>    log_analytics_destination_type = string<br>    log_analytics_workspace_id     = optional(string, null)<br><br>    diag_logs = optional(list(object({<br>      category                 = string<br>      retention_policy_enabled = bool<br>      retention_policy_days    = number<br>    })), [])<br><br>    diag_metrics = list(object({<br>      category                 = string<br>      retention_policy_enabled = bool<br>      retention_policy_days    = number<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_enable_rbac_authorization"></a> [enable\_rbac\_authorization](#input\_enable\_rbac\_authorization) | (Optional) Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions. | `bool` | `null` | no |
| <a name="input_enabled_for_deployment"></a> [enabled\_for\_deployment](#input\_enabled\_for\_deployment) | (Optional) Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault. | `bool` | `null` | no |
| <a name="input_enabled_for_disk_encryption"></a> [enabled\_for\_disk\_encryption](#input\_enabled\_for\_disk\_encryption) | (Optional) Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys. | `bool` | `null` | no |
| <a name="input_enabled_for_template_deployment"></a> [enabled\_for\_template\_deployment](#input\_enabled\_for\_template\_deployment) | (Optional) Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault. | `bool` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) The location in which to create the Kubernetes Cluster. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) Specifies the name of the Key Vault. Changing this forces a new resource to be created. The name must be globally unique. If the vault is in a recoverable state then the vault will need to be purged before reusing the name. | `string` | n/a | yes |
| <a name="input_network_acls"></a> [network\_acls](#input\_network\_acls) | (Optional) A network\_acls block that supports: `bypass`, `default_action`, `(optional) ip_rules`, `(optional) virtual_network_subnet_ids` fields | <pre>object({<br>    bypass                     = string<br>    default_action             = string<br>    ip_rules                   = optional(list(string))<br>    virtual_network_subnet_ids = optional(list(string))<br>  })</pre> | `null` | no |
| <a name="input_private_endpoint"></a> [private\_endpoint](#input\_private\_endpoint) | (Optional) Enable private endpoint for the key vault | <pre>object({<br>    name                          = string<br>    subnet_id                     = string<br>    custom_network_interface_name = optional(string, null)<br>    tags                          = optional(map(string))<br><br>    private_dns_zone_id   = string<br>  })</pre> | `null` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | (Optional) Whether public network access is allowed for this Key Vault. Defaults to true. | `bool` | `true` | no |
| <a name="input_purge_protection_enabled"></a> [purge\_protection\_enabled](#input\_purge\_protection\_enabled) | (Optional) Is Purge Protection enabled for this Key Vault? | `bool` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the resource group in which to create the Kubernetes Cluster. | `string` | n/a | yes |
| <a name="input_self_service_principal_id"></a> [self\_service\_principal\_id](#input\_self\_service\_principal\_id) | (Optional) ID of the service principal that shall have all access in the Key Vault | `string` | `""` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | (Required) The Name of the SKU used for this Key Vault. Possible values are `standard` and `premium`. | `string` | n/a | yes |
| <a name="input_soft_delete_retention_days"></a> [soft\_delete\_retention\_days](#input\_soft\_delete\_retention\_days) | (Optional) The number of days that items should be retained for once soft-deleted. This value can be between 7 and 90 (the default) days. | `number` | `90` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the resource. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_diagnostic_setting_id"></a> [diagnostic\_setting\_id](#output\_diagnostic\_setting\_id) | The ID of the Diagnostic Setting. |
| <a name="output_key_vault_id"></a> [key\_vault\_id](#output\_key\_vault\_id) | The ID of the Key Vault. |
| <a name="output_key_vault_location"></a> [key\_vault\_location](#output\_key\_vault\_location) | The location of the Key Vault. |
| <a name="output_key_vault_name"></a> [key\_vault\_name](#output\_key\_vault\_name) | The name of the Key Vault. |
| <a name="output_key_vault_tenant_id"></a> [key\_vault\_tenant\_id](#output\_key\_vault\_tenant\_id) | The tenant ID of the Key Vault. |
| <a name="output_key_vault_uri"></a> [key\_vault\_uri](#output\_key\_vault\_uri) | The URI of the Key Vault. |
| <a name="output_private_endpoint_custom_dns_configs"></a> [private\_endpoint\_custom\_dns\_configs](#output\_private\_endpoint\_custom\_dns\_configs) | The custom DNS configs of the Private Endpoint. |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | The ID of the Private Endpoint. |
| <a name="output_private_endpoint_ip_configuration"></a> [private\_endpoint\_ip\_configuration](#output\_private\_endpoint\_ip\_configuration) | The IP configuration of the Private Endpoint. |
| <a name="output_private_endpoint_network_interface"></a> [private\_endpoint\_network\_interface](#output\_private\_endpoint\_network\_interface) | The network interface of the Private Endpoint. |
| <a name="output_private_endpoint_private_dns_zone_configs"></a> [private\_endpoint\_private\_dns\_zone\_configs](#output\_private\_endpoint\_private\_dns\_zone\_configs) | The private DNS zone configs of the Private Endpoint. |
<!-- END_TF_DOCS -->