terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.30.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "rg" {
  name = "rg-jgarcia-dvfinlab"
}

resource "azurerm_container_registry" "acr" {
  name                     = "acrjgarcia123" # debe ser único globalmente
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  sku                      = "Basic"
admin_enabled              = true

}