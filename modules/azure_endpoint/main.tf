# Azure Endpoint submodule using azapi
resource "azapi_resource" "this" {
  name      = var.name
  parent_id = var.traffic_manager_profile_id
  type      = var.resource_types.network_trafficmanagerprofiles_azure_endpoints
  body = {
    properties = {
      alwaysServe      = var.always_serve
      customHeaders    = var.custom_headers != null ? [for h in var.custom_headers : { name = h.name, value = h.value }] : []
      endpointLocation = var.endpoint_location
      endpointStatus   = var.enabled ? "Enabled" : "Disabled"
      geoMapping       = var.geo_mapping
      priority         = var.priority
      subnets = var.subnets != null ? [for s in var.subnets : {
        first = s.first
        last  = s.last
        scope = s.scope
      }] : []
      targetResourceId = var.target_resource_id
      weight           = var.weight
    }
  }
  ignore_body_changes    = length(var.ignore_body_changes.network_trafficmanagerprofiles_azure_endpoints) > 0 ? var.ignore_body_changes.network_trafficmanagerprofiles_azure_endpoints : null
  ignore_null_property   = true
  replace_triggers_refs  = ["properties.subnets"]
  response_export_values = []
  retry                  = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}
