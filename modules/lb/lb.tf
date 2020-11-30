variable "name" {}
variable "location" {}
variable "resource_group_name" {}
variable "frontend_ipconfig_name" {}
variable "public_ip_address_id" {}

resource "azurerm_lb" "lb" {
  name                      = var.name
  location                  = var.location
  resource_group_name       = var.resource_group_name

  frontend_ip_configuration {
    name                    = var.frontend_ipconfig_name
    public_ip_address_id    = var.public_ip_address_id
  }
}