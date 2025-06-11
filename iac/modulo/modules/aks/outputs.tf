output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "kube_config_host" {
  value = azurerm_kubernetes_cluster.aks.kube_config[0].host
}

output "kube_config_client_certificate" {
  value = azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate
}

output "kube_config_client_key" {
  value = azurerm_kubernetes_cluster.aks.kube_config[0].client_key
}

output "kube_config_cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate
}

output "vnet_aks_id" {
  value = azurerm_virtual_network.vnet_aks.id
}

output "acr_name" {
  value = azurerm_container_registry.acr.name
}
