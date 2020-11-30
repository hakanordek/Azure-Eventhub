## Main Terraform code created to run on Version 13.5, latest version as of 11/2020
## Functions with AzureRM Version 2.37.0, latest version as of 11/2020
## Dated 11/28/2020
## Creates public ip, load balancer, eventhub and other resources that are needed by eventhub.
## Hard-coding is avoided, Modules are used. 

provider "azurerm" {
    version = "=2.37.0"
    features {}
}

# Import existing storage account where state file will be stored
data "azurerm_storage_account" "storage" {
    name                                = var.storage_account_name
    resource_group_name                 = var.storage_rg
}

# Configure backend remote state
terraform {
  backend "azurerm" {
    resource_group_name                 = "remote-state"
    storage_account_name                = "forstore"
    container_name                      = "tfstate"
    key                                 = "eventhub.tfstate"        
  }
}

# Create Resource Group for pip,load balancer,eventhub namepsace and eventhub  
module "deploy_resource_group" {
    source                              = "./modules/rg"
    name                                = "${var.project_prefix}-rg"
    location                            = var.location    
}

# Create Public static IP address that will be needed by Load balancer
module "deploy_pip" {
    source                              = "./modules/pip"
    name                                = "${var.project_prefix}-pip"
    location                            = var.location
    resource_group_name                 = module.deploy_resource_group.name
    allocation_method                   = "Static"
}

# Create Load Balancer
module "deploy_lb" {
    source                              = "./modules/lb"
    name                                = "${var.project_prefix}-lb"
    location                            = var.location
    resource_group_name                 = module.deploy_resource_group.name
    frontend_ipconfig_name              = "${var.project_prefix}-front-ip"
    public_ip_address_id                = module.deploy_pip.id 
}

# Create namespace, eventhub,rules and import log categories
module "deploy_eventhub" {
    source                              = "./modules/eventhub"   
    eventhub_ns_name                    = "${var.project_prefix}-ns"    
    location                            = var.location            
    resource_group_name                 = module.deploy_resource_group.name         
    ns_sku                              = "standard"      
    eventhub_rule_name                  = "${var.project_prefix}-rule0"       
    eventhub_name                       = "${var.project_prefix}-hub"        
    diag_name                           = "load-balancer-events"       
    target_resource_id                  = module.deploy_lb.id 
    Tags                                = {
        Environment                    = "Dev"
    }       
}