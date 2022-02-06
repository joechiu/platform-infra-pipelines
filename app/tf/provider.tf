
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.59.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}
