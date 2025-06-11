terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.30.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

##############################
# Variables y Data Sources
##############################

variable "location" {
  type    = string
  default = "ukwest"
}

data "azurerm_resource_group" "grupo2" {
  name = "rg-jgarcia-dvfinlab-uk"
}

data "azurerm_public_ip" "public_ip_pub" {
  name                = "public-ip-pub"
  resource_group_name = data.azurerm_resource_group.grupo2.name
}

data "azurerm_virtual_network" "vnet" {
  name                = "vnet-postgres"
  resource_group_name = data.azurerm_resource_group.grupo2.name
}

data "azurerm_subnet" "subnet" {
  name                 = "subnet-postgres"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.grupo2.name
}

data "azurerm_network_interface" "nic_pub" {
  name                = "nic-pub"
  resource_group_name = data.azurerm_resource_group.grupo2.name
}

##############################
# NSG
##############################

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-postgres"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.grupo2.name

  security_rule {
    name                       = "SSH-Public"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-Internal-SSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-Internal-Postgres"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "subnet_assoc" {
  subnet_id                 = data.azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

##############################
# SSH Key
##############################

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

##############################
# NIC Privada
##############################

resource "azurerm_network_interface" "nic_priv" {
  name                = "nic-priv"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.grupo2.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.5"
  }
}

##############################
# VM Privada
##############################

resource "azurerm_linux_virtual_machine" "vm_priv" {
  name                            = "vm-privada"
  resource_group_name             = data.azurerm_resource_group.grupo2.name
  location                        = var.location
  size                            = "Standard_B1ms"
  admin_username                  = "azureuser"
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.nic_priv.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  os_disk {
    name                 = "disk-priv"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

##############################
# VM Pública
##############################

resource "azurerm_linux_virtual_machine" "vm_pub" {
  name                            = "vm-publica"
  resource_group_name             = data.azurerm_resource_group.grupo2.name
  location                        = var.location
  size                            = "Standard_B1ms"
  admin_username                  = "azureuser"
  disable_password_authentication = true
  network_interface_ids           = [data.azurerm_network_interface.nic_pub.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  os_disk {
    name                 = "disk-pub"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  provisioner "file" {
    content     = tls_private_key.ssh_key.private_key_pem
    destination = "/home/azureuser/.ssh/id_rsa"

    connection {
      type        = "ssh"
      user        = "azureuser"
      private_key = tls_private_key.ssh_key.private_key_pem
      host        = data.azurerm_public_ip.public_ip_pub.ip_address
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/azureuser/.ssh/id_rsa",
      "sudo apt-get update",
      "sudo apt-get install -y software-properties-common",
      "sudo add-apt-repository --yes --update ppa:ansible/ansible",
      "sudo apt-get update",
      "sudo apt-get install -y ansible"
    ]

    connection {
      type        = "ssh"
      user        = "azureuser"
      private_key = tls_private_key.ssh_key.private_key_pem
      host        = data.azurerm_public_ip.public_ip_pub.ip_address
    }
  }
}

##############################
# Outputs SOLO los que necesitas
##############################

output "public_vm_ip" {
  value = data.azurerm_public_ip.public_ip_pub.ip_address
}

output "private_vm_internal_ip" {
  value = azurerm_network_interface.nic_priv.private_ip_address
}

output "private_key_for_github_secret" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}

# terraform output -raw private_key_for_github_secret
