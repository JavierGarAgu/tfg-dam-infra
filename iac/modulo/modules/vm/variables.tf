# modules/vm/variables.tf
variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "nic_pub_name" {
  type = string
}

variable "public_ip_address" {
  type = string
}
