# modules/vm/outputs.tf
output "private_ip" {
  value = azurerm_network_interface.nic_priv.private_ip_address
}

output "public_vm_ip" {
  value = var.public_ip_address
}

output "private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}
