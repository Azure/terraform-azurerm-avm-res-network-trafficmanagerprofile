# Main Traffic Manager Profile resource using azapi
resource "azapi_resource" "this" {
  location  = "global"
  name      = var.name
  parent_id = "/subscriptions/${local.subscription_id}/resourceGroups/${var.resource_group_name}"
  type      = "Microsoft.Network/trafficmanagerprofiles@2024-04-01-preview"
  body = {
    properties = {
      allowedEndpointRecordTypes = var.allowed_endpoint_record_types
      dnsConfig = {
        relativeName = var.dns_config.relative_name
        ttl          = var.dns_config.ttl
      }
      maxReturn = var.max_return
      monitorConfig = {
        customHeaders = var.monitor_config.custom_headers != null ? [
          for header in var.monitor_config.custom_headers : {
            name  = header.name
            value = header.value
          }
        ] : []
        expectedStatusCodeRanges = var.monitor_config.expected_status_code_ranges != null ? [
          for range in var.monitor_config.expected_status_code_ranges : {
            max = range.max
            min = range.min
          }
        ] : []
        intervalInSeconds         = var.monitor_config.interval_in_seconds
        path                      = var.monitor_config.path
        port                      = var.monitor_config.port
        protocol                  = var.monitor_config.protocol
        timeoutInSeconds          = var.monitor_config.timeout_in_seconds
        toleratedNumberOfFailures = var.monitor_config.tolerated_number_of_failures
      }
      profileStatus               = var.profile_status
      trafficRoutingMethod        = var.traffic_routing_method
      trafficViewEnrollmentStatus = var.traffic_view_enrollment_status
    }
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  tags                   = var.tags
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Azure Endpoints submodule
module "azure_endpoints" {
  source   = "./modules/azure_endpoint"
  for_each = var.azure_endpoints

  name                       = each.value.name
  target_resource_id         = each.value.target_resource_id
  traffic_manager_profile_id = azapi_resource.this.id
  always_serve               = each.value.always_serve
  custom_headers             = each.value.custom_headers
  enabled                    = each.value.enabled
  endpoint_location          = each.value.endpoint_location
  geo_mapping                = each.value.geo_mapping
  priority                   = each.value.priority
  subnets                    = each.value.subnets
  weight                     = each.value.weight
}

# External Endpoints submodule
module "external_endpoints" {
  source   = "./modules/external_endpoint"
  for_each = var.external_endpoints

  name                       = each.value.name
  target                     = each.value.target
  traffic_manager_profile_id = azapi_resource.this.id
  always_serve               = each.value.always_serve
  custom_headers             = each.value.custom_headers
  enabled                    = each.value.enabled
  endpoint_location          = each.value.endpoint_location
  geo_mapping                = each.value.geo_mapping
  priority                   = each.value.priority
  subnets                    = each.value.subnets
  weight                     = each.value.weight
}

# Nested Endpoints submodule
module "nested_endpoints" {
  source   = "./modules/nested_endpoint"
  for_each = var.nested_endpoints

  min_child_endpoints        = each.value.min_child_endpoints
  name                       = each.value.name
  target_resource_id         = each.value.target_resource_id
  traffic_manager_profile_id = azapi_resource.this.id
  always_serve               = each.value.always_serve
  custom_headers             = each.value.custom_headers
  enabled                    = each.value.enabled
  endpoint_location          = each.value.endpoint_location
  geo_mapping                = each.value.geo_mapping
  min_child_endpoints_ipv4   = each.value.min_child_endpoints_ipv4
  min_child_endpoints_ipv6   = each.value.min_child_endpoints_ipv6
  priority                   = each.value.priority
  subnets                    = each.value.subnets
  weight                     = each.value.weight
}

# Resource lock
resource "azapi_resource" "lock" {
  count = var.lock != null ? 1 : 0

  name      = coalesce(var.lock.name, "lock-${var.lock.kind}")
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Authorization/locks@2020-05-01"
  body = {
    properties = {
      level = var.lock.kind
      notes = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Role assignments
resource "azapi_resource" "role_assignment" {
  for_each = var.role_assignments

  name      = each.key
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  body = {
    properties = {
      principalId                        = each.value.principal_id
      principalType                      = each.value.principal_type
      roleDefinitionId                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : "/subscriptions/${local.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/${each.value.role_definition_id_or_name}"
      description                        = each.value.description
      conditionVersion                   = each.value.condition_version
      condition                          = each.value.condition
      delegatedManagedIdentityResourceId = each.value.delegated_managed_identity_resource_id
      # Note: each.value.skip_service_principal_aad_check is intentionally not used here.
      # This module uses azapi_resource for role assignments, and skip_service_principal_aad_check
      # is not part of the Microsoft.Authorization/roleAssignments ARM schema, so it cannot be set.
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Diagnostic settings
resource "azapi_resource" "diagnostic_setting" {
  for_each = var.diagnostic_settings

  name      = coalesce(each.value.name, "diag-${var.name}")
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Insights/diagnosticSettings@2021-05-01-preview"
  body = {
    properties = {
      eventHubAuthorizationRuleId = each.value.event_hub_authorization_rule_resource_id
      eventHubName                = each.value.event_hub_name
      logAnalyticsDestinationType = each.value.log_analytics_destination_type
      logs = concat(
        [for category in each.value.log_categories : {
          category = category
          enabled  = true
        }],
        [for group in each.value.log_groups : {
          categoryGroup = group
          enabled       = true
        }]
      )
      marketplacePartnerId = each.value.marketplace_partner_resource_id
      metrics = [for category in each.value.metric_categories : {
        category = category
        enabled  = true
      }]
      storageAccountId = each.value.storage_account_resource_id
      workspaceId      = each.value.workspace_resource_id
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}
