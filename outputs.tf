output "resource_group_name" {
  value = azurerm_resource_group.aks_demo_rg.name
}

output "resource_group_location" {
  value = azurerm_resource_group.aks_demo_rg.location
}

output "resouce_group_id" {
  value = azurerm_resource_group.aks_demo_rg.id
}

# Azure AKS Outputs

output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.aks_demo_cluster.id
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks_demo_cluster.name
}

output "aks_cluster_kubernetes_version" {
  value = "1.20.11"
}