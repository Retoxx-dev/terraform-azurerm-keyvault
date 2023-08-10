provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "this" {
  name     = "rg-terraform-northeu-001"
  location = "northeurope"
}

module "virtual-network" {
  source  = "Retoxx-dev/virtual-network/azurerm"
  version = "1.0.2"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  name          = "vnet-terraform-northeu-001"
  address_space = ["10.0.0.0/16"]

  subnets = [
    {
      name             = "snet-terraform-northeu-keyvault"
      address_prefixes = ["10.0.255.224/27"]
    }
  ]
}

resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = "vdn-kv-terraform-northeu-001"
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_id    = module.virtual-network.id
}

module "keyvault" {
  source = "../../"

  name                = "kv-terraform-northeu-001"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  sku_name = "standard"

  public_network_access_enabled = false

  access_policies = [
    {
      azure_ad_user_upns     = ["user1@example.com", "user2@example.com"]
      key_permissions         = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
      secret_permissions      = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
      certificate_permissions = ["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"]
      storage_permissions     = ["Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"]
    },
    {
      azure_ad_service_principal_names = ["aks-agentpool"]
      secret_permissions               = ["Get", "List", "Set", "Delete", "Purge"]
    },
    {
      azure_ad_group_names = ["aks-agentpool"]
      secret_permissions               = ["Get", "List", "Set", "Delete", "Purge"]
    }
  ]

  self_service_principal_id = "00000000-0000-0000-0000-000000000000"

  network_acls = {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    ip_rules                   = ["IP1"]
    virtual_network_subnet_ids = []
  }

  private_endpoint = {
    name                          = "pep-kv-terraform-northeu-001"
    subnet_id                     = module.virtual-network.subnet_ids["snet-terraform-northeu-keyvault"]
    custom_network_interface_name = "nic-kv-terraform-northeu-001"

    private_dns_zone_id = azurerm_private_dns_zone.this.id
  }
}