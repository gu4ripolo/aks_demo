# Resource group
resource "azurerm_resource_group" "aks_demo_rg" {
  location = var.rg_location
  name     = "${var.rg_name}-${var.environment}"
}

