# modules/rg/variables.tf
variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "ukwest"
}
