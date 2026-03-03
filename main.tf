resource "azurerm_resource_group" "rg" {
  name     = "a-oun-rg-${terraform.workspace}"
  location = "francecentral"
}


resource "azurerm_container_registry" "acr" { # ACR for AKS cluster
  name                = "${replace(var.fullname, "-", "")}acr${terraform.workspace}" # ACR name must be globally unique and can only contain lowercase letters and numbers
  resource_group_name = azurerm_resource_group.rg.name # ACR must be in the same region as AKS cluster
  location            = var.location # 
  sku                 = "Standard" # Standard SKU is sufficient for AKS cluster, Premium SKU is not necessary and more expensive
}