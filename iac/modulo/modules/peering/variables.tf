# modules/peering/variables.tf
variable "resource_group_name" {
  type = string
}

variable "vnet_aks_name" {
  type = string
}

variable "vnet_postgres_name" {
  type = string
}

variable "vnet_aks_id" {
  type = string
}

variable "vnet_postgres_id" {
  type = string
}
