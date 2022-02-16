# Random name
resource "random_string" "random_name" {
  length  = 6
  special = false
}

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
  address_space       = ["10.0.0.0/8"]
}

# Subnet
resource "azurerm_subnet" "aks_demo_default_subnet" {
  name                 = var.default_subnet
  resource_group_name  = azurerm_resource_group.aks_demo_rg.name
  virtual_network_name = azurerm_virtual_network.aks_demo_vnet.name
  address_prefixes     = ["10.240.0.0/16"]
}
resource "azurerm_subnet" "aks_demo_app_subnet" {
  name                 = var.app_subnet
  resource_group_name  = azurerm_resource_group.aks_demo_rg.name
  virtual_network_name = azurerm_virtual_network.aks_demo_vnet.name
  address_prefixes     = ["10.40.0.0/16"]
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


# Log analytics workspace
resource "azurerm_log_analytics_workspace" "aks_demo_logs" {
  name                = "aks-logs-${random_string.random_name.id}"
  location            = var.location
  resource_group_name = azurerm_resource_group.aks_demo_rg.name
  retention_in_days   = 30

}

# AKS
resource "azurerm_kubernetes_cluster" "aks_demo_cluster" {
  name                = "${var.aks_name}-${random_string.random_name.id}"
  location            = var.location
  resource_group_name = azurerm_resource_group.aks_demo_rg.name
  dns_prefix          = "aks-demo-ex"
  kubernetes_version  = "1.19.11"

  default_node_pool {
    name                 = "system"
    vm_size              = "Standard_DS2_V2"
    orchestrator_version = "1.19.11"
    availability_zones   = [1, 2, 3]
    enable_auto_scaling  = false
    node_count           = 1
    max_count            = null
    min_count            = null
    os_disk_size_gb      = 30
    vnet_subnet_id       = azurerm_subnet.aks_demo_default_subnet.id
    node_labels = {
      "nodepool-type" = "system"
      "environment"   = "dev"
      "nodepoolos"    = "linux"
      "app"           = "system-apps"
    }
    tags = {
      "nodepool-type" = "system"
      "environment"   = "dev"
      "nodepoolos"    = "linux"
      "app"           = "system-apps"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  addon_profile {
    azure_policy { enabled = true }
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.aks_demo_logs.id
    }
  }

  role_based_access_control {
    enabled = false
  }

  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "Standard"
  }

  tags = {
    Environment = "dev"
  }
}

# Nodepool
resource "azurerm_kubernetes_cluster_node_pool" "application" {
  name                  = "application"
  enable_auto_scaling   = false
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_demo_cluster.id
  node_count            = 1
  max_count             = null
  min_count             = null
  availability_zones    = [1, 2, 3]
  orchestrator_version  = "1.19.11"
  os_disk_size_gb       = 30
  vm_size               = "Standard_DS2_v2"
  vnet_subnet_id        = azurerm_subnet.aks_demo_app_subnet.id
  node_labels = {
    "nodepool-type" = "application"
    "environment"   = "production"
    "nodepools"     = "linux"
    "app"           = "java-apps"
  }
  tags = {
    "nodepool-type" = "application"
    "environment"   = "production"
    "nodepoolos"    = "linux"
    "app"           = "java-apps"
  }
}