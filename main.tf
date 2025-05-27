data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "azurerm_traffic_manager_profile" "this" {
  name                   = var.name
  resource_group_name    = var.resource_group_name
  traffic_routing_method = var.traffic_routing_method
  max_return             = var.traffic_routing_method == "MultiValue" ? var.max_return : null
  profile_status         = var.profile_status
  tags                   = var.tags

  dns_config {
    relative_name = var.name
    ttl           = var.ttl
  }
  monitor_config {
    port                         = var.monitor_config.port
    protocol                     = var.monitor_config.protocol
    interval_in_seconds          = var.monitor_config.interval_in_seconds
    path                         = var.monitor_config.path
    timeout_in_seconds           = var.monitor_config.timeout_in_seconds
    tolerated_number_of_failures = var.monitor_config.tolerated_number_of_failures

    dynamic "custom_header" {
      for_each = var.monitor_config.custom_headers

      content {
        name  = custom_header.value.name
        value = custom_header.value.value
      }
    }
    dynamic "expected_status_code_ranges" {
      for_each = var.monitor_config.expected_status_code_ranges

      content {
        max = length(split("-", expected_status_code_ranges.value)) > 1 ? split("-", expected_status_code_ranges.value)[1] : split("-", expected_status_code_ranges.value)[0]
        min = split("-", expected_status_code_ranges.value)[0]
      }
    }
  }
}

resource "azurerm_traffic_manager_endpoint" "this" {
  for_each = { for i, ep in var.endpoints : i => ep }

  name                = each.value.name
  profile_id          = azurerm_traffic_manager_profile.this.id
  target_resource_id  = each.value.target_resource_id
  target              = each.value.target
  type                = each.value.endpoint_type
  weight              = each.value.weight
  priority            = each.value.priority
  endpoint_location   = each.value.endpoint_location
  endpoint_status     = each.value.endpoint_status
  min_child_endpoints = each.value.min_child_endpoints
  geo_mappings        = each.value.geo_mappings

  dynamic "subnet" {
    for_each = each.value.subnets
    content {
      first = subnet.value.first
      last  = subnet.value.last
      scope = subnet.value.scope
    }
  }

  dynamic "custom_header" {
    for_each = each.value.custom_headers
    content {
      name  = custom_header.value.name
      value = custom_header.value.value
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.diagnostic_settings

  name                           = each.value.name != null ? each.value.name : "${var.name}-diagnostic-setting"
  target_resource_id             = azurerm_traffic_manager_profile.this.id
  eventhub_authorization_rule_id = each.value.event_hub_authorization_rule_resource_id
  eventhub_name                  = each.value.event_hub_name
  log_analytics_destination_type = each.value.log_analytics_destination_type
  log_analytics_workspace_id     = each.value.workspace_resource_id
  partner_solution_id            = each.value.marketplace_partner_resource_id
  storage_account_id             = each.value.storage_account_resource_id

  dynamic "enabled_log" {
    for_each = each.value.log_categories

    content {
      category = enabled_log.value
    }
  }
  dynamic "enabled_log" {
    for_each = each.value.log_groups

    content {
      category_group = enabled_log.value
    }
  }
  dynamic "metric" {
    for_each = each.value.metric_categories

    content {
      category = metric.value
    }
  }
}
