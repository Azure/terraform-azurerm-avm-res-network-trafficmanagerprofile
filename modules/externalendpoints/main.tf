resource "azapi_resource" "this" {
  type      = "Microsoft.Network/trafficManagerProfiles/ExternalEndpoints@2022-04-01"
  parent_id = var.traffic_manager_profile_id
  name      = var.name

  body = {
    properties = {
      target                = var.target
      endpointStatus        = var.endpoint_status
      weight                = var.weight
      priority              = var.priority
      endpointLocation      = var.endpoint_location
      minChildEndpoints     = var.min_child_endpoints
      geoMapping            = var.geo_mapping
      subnets               = var.subnets != null ? [
        for subnet in var.subnets : {
          first = subnet.first
          last  = subnet.last != null ? subnet.last : null
          scope = subnet.scope != null ? subnet.scope : null
        }
      ] : null
      customHeaders = var.custom_headers != null ? [
        for header in var.custom_headers : {
          name  = header.name
          value = header.value
        }
      ] : null
      endpointMonitorStatus = var.endpoint_monitor_status
      alwaysServe           = var.always_serve
    }
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
}
