terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
  required_providers {
    azuredevops = {
      source = "microsoft/azuredevops"
      version = ">=0.1.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.97.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "pat" {
  type = string
}

provider "azuredevops" {
  org_service_url       = "https://dev.azure.com/leiferiksenau"
  personal_access_token = var.pat
}

locals {
  location = "australiasoutheast"
}

resource "azurerm_resource_group" "rg" {
  location = local.location
  name     = "hreporter"
}

resource "azurerm_container_registry" "acr" {
  location            = local.location
  name                = "hreporter"
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"
  identity {
    type = "SystemAssigned"
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "cr_push" {
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "AcrPush"
  scope                = azurerm_container_registry.acr.id
}

data "azurerm_monitor_diagnostic_categories" "acr" {
  resource_id = azurerm_container_registry.acr.id
}
#
#resource "azurerm_log_analytics_workspace" "law" {
#  location            = local.location
#  name                = "hreporter"
#  resource_group_name = azurerm_resource_group.rg.name
#}
#
#resource "azurerm_monitor_diagnostic_setting" "acr" {
#  name                       = azurerm_container_registry.acr.name
#  target_resource_id         = azurerm_container_registry.acr.id
#  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
#
#  dynamic log {
#    for_each = toset(data.azurerm_monitor_diagnostic_categories.acr.logs)
#    content {
#      category = log.value
#      enabled  = true
#      retention_policy {
#        enabled = true
#        days    = 365 # azure limit
#      }
#    }
#  }
#
#  metric {
#    category = "AllMetrics"
#    enabled  = true
#    retention_policy {
#      enabled = true
#      days    = 365 # azure limit
#    }
#  }
#}
