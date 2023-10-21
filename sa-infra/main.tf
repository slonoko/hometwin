# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.77.0"
    }
  }

    backend "azurerm" {
        resource_group_name  = "tf-state-rg"
        storage_account_name = "tfstatefileuploader"
        container_name       = "state"
        key                  = "terraform.tfstate"
    }


  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "rg" {
  name     = "rg-sa-dev"
  location = "westeurope"
}

resource "azurerm_digital_twins_instance" "smarthometwin" {
  name                = "smarthome-twin"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  identity {
    type = "SystemAssigned"
  }
}