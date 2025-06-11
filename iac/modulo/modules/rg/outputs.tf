# modules/rg/outputs.tf
output "resource_group_name" {
  value = azurerm_resource_group.grupo2.name
}

output "location" {
  value = azurerm_resource_group.grupo2.location
}

output "public_ip_id" {
  value = azurerm_public_ip.public_ip_pub.id
}

output "subnet_id" {
  value = azurerm_subnet.subnet.id
}

output "nic_pub_id" {
  value = azurerm_network_interface.nic_pub.id
}

output "public_ip_address" {
  value = azurerm_public_ip.public_ip_pub.ip_address
}
output "vnet_postgres_id" {
  value = azurerm_virtual_network.vnet.id
}
