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

resource "azurerm_storage_account" "storage" {
  name                     = "strtwin"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "iotcontainer" {
  name                  = "iotcontainer"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}


resource "azurerm_iothub" "smartiothub" {
  name                         = "smartiothub70"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  local_authentication_enabled = false

  sku {
    name     = "S1"
    capacity = "1"
  }
}

resource "azurerm_service_plan" "devclo" {
  name                = "devclo-app-service-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "fnctdevclo" {
  name                = "fnctdevclo-linux-function-app"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  service_plan_id            = azurerm_service_plan.devclo.id

  site_config {}
}