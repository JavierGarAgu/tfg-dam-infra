terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.30.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# =========================
# Variables (por si querés parametrizar más adelante)
# =========================

variable "resource_group_name" {
  default = "rg-jgarcia-dvfinlab-uk"
}

variable "vnet_aks_name" {
  default = "vnet-aks"
}

variable "vnet_postgres_name" {
  default = "vnet-postgres"
}

# =========================
# Data sources: Buscar VNets existentes
# =========================

data "azurerm_virtual_network" "vnet_aks" {
  name                = var.vnet_aks_name
  resource_group_name = var.resource_group_name
}

data "azurerm_virtual_network" "vnet_postgres" {
  name                = var.vnet_postgres_name
  resource_group_name = var.resource_group_name
}

# =========================
# Peering desde AKS hacia Postgres
# =========================

resource "azurerm_virtual_network_peering" "aks_to_postgres" {
  name                      = "peering-aks-to-postgres"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.vnet_aks.name
  remote_virtual_network_id = data.azurerm_virtual_network.vnet_postgres.id
  allow_forwarded_traffic   = true
  allow_virtual_network_access = true
}

# =========================
# Peering desde Postgres hacia AKS
# =========================

resource "azurerm_virtual_network_peering" "postgres_to_aks" {
  name                      = "peering-postgres-to-aks"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.vnet_postgres.name
  remote_virtual_network_id = data.azurerm_virtual_network.vnet_aks.id
  allow_forwarded_traffic   = true
  allow_virtual_network_access = true
}

# =========================
# Output
# =========================

output "peering_establecido" {
  value = "Peering bidireccional entre '${var.vnet_aks_name}' y '${var.vnet_postgres_name}' creado con éxito."
}
