# Traffic Manager Profile resource using azapi
resource "azapi_resource" "this" {
  type      = "Microsoft.Network/trafficManagerProfiles@2022-04-01"
  parent_id = data.azurerm_resource_group.this.id
  name      = var.name
  location  = "global" # Traffic Manager profiles are always global

  body = {
    properties = {
      profileStatus        = var.profile_status
      trafficRoutingMethod = var.traffic_routing_method
      dnsConfig = {
        relativeName = var.dns_config.relative_name
        ttl          = var.dns_config.ttl
      }
      monitorConfig = {
        protocol                  = var.monitor_config.protocol
        port                      = var.monitor_config.port
        path                      = var.monitor_config.path
        intervalInSeconds         = var.monitor_config.interval_in_seconds
        timeoutInSeconds          = var.monitor_config.timeout_in_seconds
        toleratedNumberOfFailures = var.monitor_config.tolerated_number_of_failures
        customHeaders = var.monitor_config.custom_headers != null ? [
          for header in var.monitor_config.custom_headers : {
            name  = header.name
            value = header.value
          }
        ] : null
        expectedStatusCodeRanges = var.monitor_config.expected_status_code_ranges != null ? [
          for range in var.monitor_config.expected_status_code_ranges : {
            min = range.min
            max = range.max
          }
        ] : null
      }
      trafficViewEnrollmentStatus = var.traffic_view_enrollment_status
      maxReturn                   = var.max_return
    }
    tags = var.tags
  }

  response_export_values = ["*"]

  schema_validation_enabled = false

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  lifecycle {
    ignore_changes = [
      body.tags
    ]
  }
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Data source to get the resource group
data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

# required AVM resources interfaces
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azapi_resource.this.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azapi_resource.this.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}
