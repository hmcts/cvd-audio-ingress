terraform {
  backend "azurerm" {
  }
  required_version = ">= 1.3.7"
  required_providers {
    azurerm  = ">= 2.34.0"
    template = "~> 2.1"
    random   = ">= 2"
  }
}
