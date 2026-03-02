resource "azurerm_resource_group" "rg" {
  name     = "a-oun-rg-${terraform.workspace}"
  location = "francecentral"
}