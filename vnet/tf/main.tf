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
    name      = var.rg
    location  = var.location
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
    name                = var.vnet
    resource_group_name = azurerm_resource_group.rg.name
    address_space       = [var.vnet_cidr]
    location            = var.location
    tags = {
        environment = var.tag
    }
}

resource "azurerm_subnet" "snet" {
  count                = "${length(var.snet_cidr)}"
  name                 = element(var.snet, count.index)
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefixes     = [element(var.snet_cidr, count.index)]
}
