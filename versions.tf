terraform {
  required_version = ">= 1.3.1"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.65"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = ">=2.41"
    }
  }
}