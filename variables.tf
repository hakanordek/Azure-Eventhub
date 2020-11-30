variable "storage_account_name" {
    type                = string
    description         = "Name of storage account where state file stored"
}

variable "storage_rg" {
    type                = string
    description         = "Resource group name of storage account where state file stored"
}

variable "project_prefix" {
    type                = string
    description         = "Project prefix"
}

variable "location" {
    type                = string
    description         = "Azure region"
}