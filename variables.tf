# Traffic Manager Profile specific variables
variable "dns_config" {
  type = object({
    relative_name = string
    ttl           = number
  })
  description = <<DESCRIPTION
The DNS settings of the Traffic Manager profile.
- `relative_name` - (Required) The relative DNS name provided by this Traffic Manager profile. This value is combined with the DNS domain name used by Azure Traffic Manager to form the fully-qualified domain name (FQDN) of the profile.
- `ttl` - (Required) The DNS Time-To-Live (TTL), in seconds. This informs the local DNS resolvers and DNS clients how long to cache DNS responses provided by this Traffic Manager profile. Valid values are between 0 and 2147483647.
DESCRIPTION

  validation {
    condition     = var.dns_config.ttl >= 0 && var.dns_config.ttl <= 2147483647
    error_message = "TTL must be between 0 and 2147483647."
  }
}

variable "monitor_config" {
  type = object({
    protocol                     = string
    port                         = number
    path                         = optional(string, "/")
    interval_in_seconds          = optional(number, 30)
    timeout_in_seconds           = optional(number, 10)
    tolerated_number_of_failures = optional(number, 3)
    custom_headers = optional(list(object({
      name  = string
      value = string
    })), [])
    expected_status_code_ranges = optional(list(object({
      min = number
      max = number
    })), [])
  })
  description = <<DESCRIPTION
The endpoint monitoring settings of the Traffic Manager profile.
- `protocol` - (Required) The protocol (HTTP, HTTPS or TCP) used to probe for endpoint health.
- `port` - (Required) The TCP port used to probe for endpoint health.
- `path` - (Optional) The path relative to the endpoint domain name used to probe for endpoint health. Defaults to "/".
- `interval_in_seconds` - (Optional) The monitor interval for endpoints in this profile. Defaults to 30.
- `timeout_in_seconds` - (Optional) The monitor timeout for endpoints in this profile. Defaults to 10.
- `tolerated_number_of_failures` - (Optional) The number of consecutive failed health checks. Defaults to 3.
- `custom_headers` - (Optional) List of custom headers for monitoring.
- `expected_status_code_ranges` - (Optional) List of expected status code ranges.
DESCRIPTION

  validation {
    condition     = contains(["HTTP", "HTTPS", "TCP"], var.monitor_config.protocol)
    error_message = "Monitor protocol must be one of: 'HTTP', 'HTTPS', 'TCP'."
  }
  validation {
    condition     = var.monitor_config.port >= 1 && var.monitor_config.port <= 65535
    error_message = "Monitor port must be between 1 and 65535."
  }
}

variable "name" {
  type        = string
  description = "The name of the Traffic Manager Profile."

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]$", var.name)) || can(regex("^[a-zA-Z0-9]$", var.name))
    error_message = "The name must be between 1 and 63 characters long, can only contain alphanumeric characters and hyphens, and must start and end with an alphanumeric character."
  }
}

# This is required for most resource modules
variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

variable "traffic_routing_method" {
  type        = string
  description = "The traffic routing method of the Traffic Manager profile. Possible values are 'Geographic', 'MultiValue', 'Performance', 'Priority', 'Subnet', 'Weighted'."

  validation {
    condition     = contains(["Geographic", "MultiValue", "Performance", "Priority", "Subnet", "Weighted"], var.traffic_routing_method)
    error_message = "Traffic routing method must be one of: 'Geographic', 'MultiValue', 'Performance', 'Priority', 'Subnet', 'Weighted'."
  }
}

variable "allowed_endpoint_record_types" {
  type        = list(string)
  default     = null
  description = "The list of allowed endpoint record types. Possible values are 'Any', 'DomainName', 'IPv4Address', 'IPv6Address'."

  validation {
    condition     = var.allowed_endpoint_record_types == null || alltrue([for t in coalesce(var.allowed_endpoint_record_types, []) : contains(["Any", "DomainName", "IPv4Address", "IPv6Address"], t)])
    error_message = "Allowed endpoint record types must be one of: 'Any', 'DomainName', 'IPv4Address', 'IPv6Address'."
  }
}

# Endpoint variables
variable "azure_endpoints" {
  type = map(object({
    name               = string
    target_resource_id = string
    enabled            = optional(bool, true)
    weight             = optional(number)
    priority           = optional(number)
    endpoint_location  = optional(string)
    geo_mapping        = optional(list(string))
    always_serve       = optional(string, "Disabled")
    custom_headers = optional(list(object({
      name  = string
      value = string
    })), [])
    subnets = optional(list(object({
      first = string
      last  = optional(string)
      scope = optional(number)
    })), [])
  }))
  default     = {}
  description = <<DESCRIPTION
A map of Azure endpoints to create. The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.
- `name` - (Required) The name of the endpoint.
- `target_resource_id` - (Required) The Azure Resource URI of the endpoint.
- `enabled` - (Optional) Whether the endpoint is enabled. Defaults to true.
- `weight` - (Optional) The weight of this endpoint (1-1000) for Weighted routing.
- `priority` - (Optional) The priority of this endpoint (1-1000) for Priority routing.
- `endpoint_location` - (Optional) The location of the endpoint for Performance routing.
- `geo_mapping` - (Optional) List of geographic regions for Geographic routing.
- `always_serve` - (Optional) If Always Serve is enabled. Defaults to "Disabled".
- `custom_headers` - (Optional) List of custom headers.
- `subnets` - (Optional) List of subnets for Subnet routing.
DESCRIPTION
  nullable    = false
}

variable "diagnostic_settings" {
  type = map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.
DESCRIPTION
  nullable    = false

  validation {
    condition     = alltrue([for _, v in var.diagnostic_settings : contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)])
    error_message = "Log analytics destination type must be one of: 'Dedicated', 'AzureDiagnostics'."
  }
  validation {
    condition = alltrue(
      [
        for _, v in var.diagnostic_settings :
        v.workspace_resource_id != null || v.storage_account_resource_id != null || v.event_hub_authorization_rule_resource_id != null || v.marketplace_partner_resource_id != null
      ]
    )
    error_message = "At least one of `workspace_resource_id`, `storage_account_resource_id`, `marketplace_partner_resource_id`, or `event_hub_authorization_rule_resource_id`, must be set."
  }
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "external_endpoints" {
  type = map(object({
    name              = string
    target            = string
    enabled           = optional(bool, true)
    weight            = optional(number)
    priority          = optional(number)
    endpoint_location = optional(string)
    geo_mapping       = optional(list(string))
    always_serve      = optional(string, "Disabled")
    custom_headers = optional(list(object({
      name  = string
      value = string
    })), [])
    subnets = optional(list(object({
      first = string
      last  = optional(string)
      scope = optional(number)
    })), [])
  }))
  default     = {}
  description = <<DESCRIPTION
A map of external endpoints to create. The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.
- `name` - (Required) The name of the endpoint.
- `target` - (Required) The fully-qualified DNS name or IP address of the endpoint.
- `enabled` - (Optional) Whether the endpoint is enabled. Defaults to true.
- `weight` - (Optional) The weight of this endpoint (1-1000) for Weighted routing.
- `priority` - (Optional) The priority of this endpoint (1-1000) for Priority routing.
- `endpoint_location` - (Optional) The location of the endpoint for Performance routing.
- `geo_mapping` - (Optional) List of geographic regions for Geographic routing.
- `always_serve` - (Optional) If Always Serve is enabled. Defaults to "Disabled".
- `custom_headers` - (Optional) List of custom headers.
- `subnets` - (Optional) List of subnets for Subnet routing.
DESCRIPTION
  nullable    = false
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "The lock level must be one of: 'None', 'CanNotDelete', or 'ReadOnly'."
  }
}

variable "max_return" {
  type        = number
  default     = null
  description = "Maximum number of endpoints to be returned for MultiValue routing type."
}

variable "nested_endpoints" {
  type = map(object({
    name                     = string
    target_resource_id       = string
    min_child_endpoints      = number
    enabled                  = optional(bool, true)
    weight                   = optional(number)
    priority                 = optional(number)
    endpoint_location        = optional(string)
    geo_mapping              = optional(list(string))
    min_child_endpoints_ipv4 = optional(number)
    min_child_endpoints_ipv6 = optional(number)
    always_serve             = optional(string, "Disabled")
    custom_headers = optional(list(object({
      name  = string
      value = string
    })), [])
    subnets = optional(list(object({
      first = string
      last  = optional(string)
      scope = optional(number)
    })), [])
  }))
  default     = {}
  description = <<DESCRIPTION
A map of nested endpoints to create. The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.
- `name` - (Required) The name of the endpoint.
- `target_resource_id` - (Required) The resource ID of the nested Traffic Manager profile.
- `min_child_endpoints` - (Required) The minimum number of endpoints that must be available in the child profile.
- `enabled` - (Optional) Whether the endpoint is enabled. Defaults to true.
- `weight` - (Optional) The weight of this endpoint (1-1000) for Weighted routing.
- `priority` - (Optional) The priority of this endpoint (1-1000) for Priority routing.
- `endpoint_location` - (Optional) The location of the endpoint for Performance routing.
- `geo_mapping` - (Optional) List of geographic regions for Geographic routing.
- `min_child_endpoints_ipv4` - (Optional) Minimum number of IPv4 endpoints.
- `min_child_endpoints_ipv6` - (Optional) Minimum number of IPv6 endpoints.
- `always_serve` - (Optional) If Always Serve is enabled. Defaults to "Disabled".
- `custom_headers` - (Optional) List of custom headers.
- `subnets` - (Optional) List of subnets for Subnet routing.
DESCRIPTION
  nullable    = false
}

variable "profile_status" {
  type        = string
  default     = "Enabled"
  description = "The status of the Traffic Manager profile. Possible values are 'Enabled' or 'Disabled'."

  validation {
    condition     = contains(["Enabled", "Disabled"], var.profile_status)
    error_message = "Profile status must be one of: 'Enabled', 'Disabled'."
  }
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
DESCRIPTION
  nullable    = false
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

variable "traffic_view_enrollment_status" {
  type        = string
  default     = null
  description = "Indicates whether Traffic View is 'Enabled' or 'Disabled' for the Traffic Manager profile."

  validation {
    condition     = var.traffic_view_enrollment_status == null || contains(["Enabled", "Disabled"], var.traffic_view_enrollment_status)
    error_message = "Traffic view enrollment status must be one of: 'Enabled', 'Disabled'."
  }
}
