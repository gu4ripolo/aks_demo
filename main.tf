# Resource group
resource "azurerm_resource_group" "aks_demo_rg" {
  location = var.location
  name     = "${var.rg_name}-${var.environment}"
}

# Network Security Group
resource "azurerm_network_security_group" "aks_demo_nsg" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = azurerm_resource_group.aks_demo_rg.name
}

# Virtual Network
resource "azurerm_virtual_network" "aks_demo_vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = azurerm_resource_group.aks_demo_rg.name
  address_space       = ["10.0.0.0/16"]
}

# Subnet
resource "azurerm_subnet" "aks_demo_default_subnet" {
  name                 = var.default_subnet
  resource_group_name  = azurerm_resource_group.aks_demo_rg.name
  virtual_network_name = azurerm_virtual_network.aks_demo_vnet.name
  address_prefixes     = ["10.0.1.0/26"]
}
resource "azurerm_subnet" "aks_demo_app_subnet" {
  name                 = var.app_subnet
  resource_group_name  = azurerm_resource_group.aks_demo_rg.name
  virtual_network_name = azurerm_virtual_network.aks_demo_vnet.name
  address_prefixes     = ["10.0.4.0/26"]
}

# Subnet and NSG association
resource "azurerm_subnet_network_security_group_association" "aks_demo_default_subnet_nsg" {
  network_security_group_id = azurerm_network_security_group.aks_demo_nsg.id
  subnet_id                 = azurerm_subnet.aks_demo_default_subnet.id
}

resource "azurerm_subnet_network_security_group_association" "aks_demo_app_subnet_nsg" {
  network_security_group_id = azurerm_network_security_group.aks_demo_nsg.id
  subnet_id                 = azurerm_subnet.aks_demo_app_subnet.id
}