# Nested Endpoint submodule using azapi
resource "azapi_resource" "this" {
  name      = var.name
  parent_id = var.traffic_manager_profile_id
  type      = "Microsoft.Network/trafficmanagerprofiles/NestedEndpoints@2024-04-01-preview"
  body = {
    properties = {
      alwaysServe           = var.always_serve
      customHeaders         = var.custom_headers != null ? [for h in var.custom_headers : { name = h.name, value = h.value }] : []
      endpointLocation      = var.endpoint_location
      endpointStatus        = var.enabled ? "Enabled" : "Disabled"
      geoMapping            = var.geo_mapping
      minChildEndpoints     = var.min_child_endpoints
      minChildEndpointsIPv4 = var.min_child_endpoints_ipv4
      minChildEndpointsIPv6 = var.min_child_endpoints_ipv6
      priority              = var.priority
      subnets = var.subnets != null ? [for s in var.subnets : {
        first = s.first
        last  = s.last
        scope = s.scope
      }] : []
      targetResourceId = var.target_resource_id
      weight           = var.weight
    }
  }
  response_export_values = []

  lifecycle {
    ignore_changes = [
      body.properties.endpointLocation,
      body.properties.priority,
    ]
  }
}
