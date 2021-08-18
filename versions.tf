terraform {
  backend "azurerm" {
  }

  required_version = ">= 0.15.4"
  required_providers {
    azurerm = ">= 2.7.0"
  }
}
