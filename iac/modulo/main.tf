## main.tf

terraform {

  backend "azurerm" {
    resource_group_name   = "rg-jgarcia-dvfinlab"
    storage_account_name  = "stajgarciadvfinlab"
    container_name        = "estado"
    key                   = "terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}


provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = module.aks.kube_config_host
  client_certificate     = base64decode(module.aks.kube_config_client_certificate)
  client_key             = base64decode(module.aks.kube_config_client_key)
  cluster_ca_certificate = base64decode(module.aks.kube_config_cluster_ca_certificate)
}

## variables.tf

variable "location" {
  type    = string
  default = "ukwest"
}

variable "resource_group_name" {
  type = string
  default = "rg-jgarcia-dvfinlab-uk"
}


resource "random_string" "sufijo" {
  length  = 6
  special = false
  upper   = false
}

module "rg" {
  source              = "./modules/rg"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "vm" {
  source              = "./modules/vm"
  resource_group_name = module.rg.resource_group_name
  location            = module.rg.location
  subnet_name         = "subnet-postgres"
  vnet_name           = "vnet-postgres"
  nic_pub_name        = "nic-pub"
  public_ip_address   = module.rg.public_ip_address

  depends_on = [module.rg]
}

module "aks" {
  source              = "./modules/aks"
  resource_group_name = module.rg.resource_group_name
  location            = module.rg.location
  acr_name            = "acrjgarcia${random_string.sufijo.result}"
  vnet_aks_name       = "vnet-aks"
  subnet_aks_name     = "subnet-aks"
  aks_name            = "aksjgarcia${random_string.sufijo.result}"
  dns_prefix          = "aksjgarcia${random_string.sufijo.result}"

  depends_on = [module.rg]
}

module "peering" {
  source              = "./modules/peering"
  resource_group_name = module.rg.resource_group_name
  vnet_aks_name       = "vnet-aks"
  vnet_postgres_name  = "vnet-postgres"
  vnet_aks_id         = module.aks.vnet_aks_id
  vnet_postgres_id    = module.rg.vnet_postgres_id 

  depends_on = [
    module.aks,
    module.vm
  ]
}

## outputs.tf

output "vm_private_ip" {
  value = module.vm.private_ip
}

output "vm_public_ip" {
  value = module.vm.public_vm_ip
}

output "vm_private_key" {
  value     = module.vm.private_key
  sensitive = true
}

output "aks_name" {
  value = module.aks.aks_name
}

output "acr_name" {
  value = module.aks.acr_name
}
output "resource_group_name" {
  value = module.rg.resource_group_name
}