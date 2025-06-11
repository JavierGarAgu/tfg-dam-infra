terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.30.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.22.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
}

data "azurerm_client_config" "current" {}

variable "location" {
  description = "Ubicación (región) donde se desplegarán todos los recursos de Azure"
  type        = string
  default     = "ukwest" 
}

data "azurerm_resource_group" "grupo2" {
  name     = "rg-jgarcia-dvfinlab-uk"
#  location = var.location
}

resource "azurerm_container_registry" "acr" {
  name                = "acrjgarcia123"
  resource_group_name = data.azurerm_resource_group.grupo2.name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false  # NO necesitas admin_enabled si usás identidad managed
}

resource "azurerm_virtual_network" "vnet_aks" {
  name                = "vnet-aks"
  address_space       = ["10.200.0.0/16"]
  location            = var.location
  resource_group_name = data.azurerm_resource_group.grupo2.name
}

resource "azurerm_subnet" "subnet_aks" {
  name                 = "subnet-aks"
  resource_group_name  = data.azurerm_resource_group.grupo2.name
  virtual_network_name = azurerm_virtual_network.vnet_aks.name
  address_prefixes     = ["10.200.1.0/24"]
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-jga"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.grupo2.name
  dns_prefix          = "aksjga"

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_B2s"
    vnet_subnet_id = azurerm_subnet.subnet_aks.id
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

# ASIGNACIÓN CORRECTA del rol AcrPull a la identidad del kubelet (nodos)
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

resource "kubernetes_namespace" "pruebas" {
  metadata {
    name = "pruebas"
  }
}

# No necesitas crear secret docker ni service account para imagenes privadas
# La identidad managed del kubelet con rol AcrPull lo hace automático

resource "kubernetes_cluster_role_binding" "admin_binding" {
  metadata {
    name = "terraform-admin-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "User"
    name      = data.azurerm_client_config.current.client_id
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_service" "pruebas_lb" {
  metadata {
    name      = "pruebas-service"
    namespace = kubernetes_namespace.pruebas.metadata[0].name
  }

  spec {
    type = "LoadBalancer"

    port {
      port = 80
    }
  }
}

output "pruebas_lb_ip" {
  value       = kubernetes_service.pruebas_lb.status[0].load_balancer[0].ingress[0].ip
  description = "IP pública del LoadBalancer pruebas"
}
