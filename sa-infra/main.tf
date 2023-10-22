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


resource "azurerm_log_analytics_workspace" "logs" {
  name                = "twin-logs"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 120
}

resource "azurerm_application_insights" "insights" {
  name                = "twin-appinsights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.logs.id
  application_type    = "other"
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

  site_config {
    application_stack {
      python_version = "3.8"
    } 
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_eventgrid_system_topic" "eventtopic" {
  name                   = "sensors"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  source_arm_resource_id = azurerm_iothub.smartiothub.id
  topic_type             = "Microsoft.Devices.IoTHubs"
}

resource "azurerm_eventgrid_system_topic_event_subscription" "eventiottodt" {
  name  = "eventiottodt22"
  resource_group_name = azurerm_resource_group.rg.name
  system_topic = azurerm_eventgrid_system_topic.eventtopic.name
  event_delivery_schema = "EventGridSchema"
  included_event_types = [ "Microsoft.Devices.DeviceTelemetry" ]
  advanced_filtering_on_arrays_enabled = true

  azure_function_endpoint {
    max_events_per_batch = 1
    preferred_batch_size_in_kilobytes = 64
    function_id = "${azurerm_linux_function_app.fnctdevclo.id}/functions/devtocloudevent"
  }
}

resource "azurerm_monitor_diagnostic_setting" "store_diagnostics" {
  name = "twin-diagnostic-fct"

  target_resource_id         = azurerm_linux_function_app.fnctdevclo.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id

  metric {
    enabled = true
    category = "AllMetrics"
  }
}