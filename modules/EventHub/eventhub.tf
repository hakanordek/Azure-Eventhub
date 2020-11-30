variable "eventhub_ns_name" {
  type        = string
  description = "Specifies the name of the EventHub Namespace resource."
}
variable "location" {
  type        = string
  description = "Specifies the supported Azure location where the resource exists."
}
variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the namespace."
}
variable "ns_sku" {
  type        = string
  description = "Defines which tier to use. Valid options are Basic and Standard "
}
variable "eventhub_rule_name" {
  type        = string
  description = "Specifies the name of the Authorization Rule."
}
variable "eventhub_name" {
  type        = string
  description = "Specifies the name of the EventHub resource."
}
variable "diag_name" {
  type        = string
  description = "Specifies the name of the Diagnostic Setting."
}
variable "target_resource_id" {
  type        = string
  description = "The ID of an existing Resource on which to configure Diagnostic Settings."
}
variable "Tags" {
	type        = map
	default     = {}
	description = "A map of the tags to use on the resources that are deployed with this module."
}

# Importing Diagnostic Categories since each resource has different type and number of log category.
data "azurerm_monitor_diagnostic_categories" "diag_category" {
  resource_id                       = var.target_resource_id
}

# Local variables for Eventhub and eventhub namespace
locals {
  listen                            = true 
  send                              = true
  manage                            = true
  partition_count                   = "1"
  message_retention                 = "7" 
}   

# Create eventhub namespace
resource "azurerm_eventhub_namespace" "eventhub_ns" {
  name                              = var.eventhub_ns_name
  location                          = var.location
  resource_group_name               = var.resource_group_name
  sku                               = var.ns_sku
  tags                              = var.Tags    
}

# Create eventhub namespace rules
resource "azurerm_eventhub_namespace_authorization_rule" "eventhub_rule" {
  name                              = var.eventhub_rule_name
  namespace_name                    = azurerm_eventhub_namespace.eventhub_ns.name
  resource_group_name               = var.resource_group_name

  listen                            = local.listen
  send                              = local.send 
  manage                            = local.manage 
}

# Create eventhub
resource "azurerm_eventhub" "eventhub" {
  name                              = var.eventhub_name
  namespace_name                    = azurerm_eventhub_namespace.eventhub_ns.name 
  resource_group_name               = var.resource_group_name
  partition_count                   = local.partition_count
  message_retention                 = local.message_retention
}

# Create monitor diagnostic setting
resource "azurerm_monitor_diagnostic_setting" "event-stream" {
  name                              = var.diag_name
  target_resource_id                = var.target_resource_id 
  eventhub_name                     = var.eventhub_name
  eventhub_authorization_rule_id    = azurerm_eventhub_namespace_authorization_rule.eventhub_rule.id 
    
  dynamic "log" {
    for_each                        = data.azurerm_monitor_diagnostic_categories.diag_category.logs

    content {
      category                      = log.value
      enabled                       = true
      retention_policy {
        enabled                     = true 
      }
    }
  }
}