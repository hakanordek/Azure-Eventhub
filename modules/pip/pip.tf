variable "name" {}
variable "location" {}
variable "resource_group_name" {}
variable "allocation_method" {}

resource "azurerm_public_ip" "pip" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.allocation_method
}