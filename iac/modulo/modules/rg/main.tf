resource "azurerm_resource_group" "grupo2" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_public_ip" "public_ip_pub" {
  name                = "public-ip-pub"
  location            = var.location
  resource_group_name = azurerm_resource_group.grupo2.name
  allocation_method   = "Static"
  sku                 = "Basic"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-postgres"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.grupo2.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-postgres"
  resource_group_name  = azurerm_resource_group.grupo2.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic_pub" {
  name                = "nic-pub"
  location            = var.location
  resource_group_name = azurerm_resource_group.grupo2.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.4"
    public_ip_address_id          = azurerm_public_ip.public_ip_pub.id
  }
}
