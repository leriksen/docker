data "azuredevops_project" "docker" {
  name = "docker"
}

data "azurerm_subscription" "sub" {
  subscription_id = data.azurerm_client_config.current.subscription_id
}

resource "azuredevops_serviceendpoint_azurecr" "se_acr" {
  project_id                = data.azuredevops_project.docker.id
  service_endpoint_name     = "ACR"
  resource_group            = azurerm_resource_group.rg.name
  azurecr_spn_tenantid      = data.azurerm_client_config.current.tenant_id
  azurecr_name              = azurerm_container_registry.acr.name
  azurecr_subscription_id   = data.azurerm_client_config.current.subscription_id
  azurecr_subscription_name = data.azurerm_subscription.sub.display_name
}

resource "azuredevops_resource_authorization" "se_acr_auth" {
  project_id  = data.azuredevops_project.docker.id
  resource_id = azuredevops_serviceendpoint_azurecr.se_acr.id
  authorized  = true
}
