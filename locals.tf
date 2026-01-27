locals {
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
  subscription_id                    = coalesce(data.azapi_client_config.this.subscription_id, "")
}

data "azapi_client_config" "this" {}
