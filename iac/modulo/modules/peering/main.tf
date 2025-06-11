## Módulo Peering
# modules/peering/main.tf
resource "azurerm_virtual_network_peering" "peer_aks_to_postgres" {
  name                      = "peer-aks-to-postgres"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = var.vnet_aks_name
  remote_virtual_network_id = var.vnet_postgres_id
  allow_forwarded_traffic   = true
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "peer_postgres_to_aks" {
  name                      = "peer-postgres-to-aks"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = var.vnet_postgres_name
  remote_virtual_network_id = var.vnet_aks_id
  allow_forwarded_traffic   = true
  allow_virtual_network_access = true
}