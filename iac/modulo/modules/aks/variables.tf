# modules/aks/variables.tf
variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "acr_name" {
  type = string
}

variable "vnet_aks_name" {
  type = string
}

variable "subnet_aks_name" {
  type = string
}

variable "aks_name" {
  type = string
}

variable "dns_prefix" {
  type = string
}

