terraform {
  required_version = ">= 0.12"
}

provider "azurerm" {
  features {}
}

locals {
  idx = format("%03d", var.instance_count)
  postfix = format("%s-%03d", var.postfix, var.instance_count)
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "rg" {
    name     = "rg-${var.rg}-${local.postfix}"
    location = var.location
    tags = {
        environment = var.tag
    }
}

# Create virtual network
resource "azurerm_virtual_network" "rg" {
    name                = "${var.rg}-vnet-${local.postfix}"
    address_space       = [var.vnet_cidr]
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name
    tags = {
        environment = var.tag
    }
}

# Create subnet
resource "azurerm_subnet" "rg" {
    name                 = "${var.rg}-snet-${local.postfix}"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.rg.name
    address_prefixes     = [var.subnet_cidr]
}

