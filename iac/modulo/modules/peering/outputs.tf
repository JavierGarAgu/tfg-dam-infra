# modules/peering/outputs.tf
output "peering_aks_to_postgres" {
  value = azurerm_virtual_network_peering.peer_aks_to_postgres.id
}

output "peering_postgres_to_aks" {
  value = azurerm_virtual_network_peering.peer_postgres_to_aks.id
}
