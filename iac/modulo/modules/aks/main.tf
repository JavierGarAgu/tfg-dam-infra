## Módulo AKS
# modules/aks/main.tf
data "azurerm_resource_group" "grupo2" {
  name = var.resource_group_name
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = data.azurerm_resource_group.grupo2.name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
}

resource "azurerm_virtual_network" "vnet_aks" {
  name                = var.vnet_aks_name
  address_space       = ["10.200.0.0/16"]
  location            = var.location
  resource_group_name = data.azurerm_resource_group.grupo2.name
}

resource "azurerm_subnet" "subnet_aks" {
  name                 = var.subnet_aks_name
  resource_group_name  = data.azurerm_resource_group.grupo2.name
  virtual_network_name = azurerm_virtual_network.vnet_aks.name
  address_prefixes     = ["10.200.1.0/24"]
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.grupo2.name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name                = "default"
    vm_size             = "Standard_B2s"
    vnet_subnet_id      = azurerm_subnet.subnet_aks.id

    enable_auto_scaling = true
    min_count           = 1
    max_count           = 2
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    dns_service_ip = "10.2.0.10"
    service_cidr   = "10.2.0.0/24"
  }
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}
