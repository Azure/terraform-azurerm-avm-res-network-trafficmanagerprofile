variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed. For Traffic Manager profiles, this is not used as they are global, but kept for AVM interface compatibility."
  nullable    = false
  default     = "global"
}

variable "name" {
  type        = string
  description = "The name of the Traffic Manager profile. Must be unique within the trafficmanager.net DNS zone."

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$", var.name))
    error_message = "The name must be between 1 and 63 characters long, start and end with a letter or number, and can only contain lowercase letters, numbers, and hyphens."
  }
}

# This is required for most resource modules
variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

# Traffic Manager Profile specific variables
variable "profile_status" {
  type        = string
  default     = "Enabled"
  description = "The status of the Traffic Manager profile. Possible values are 'Enabled' and 'Disabled'."
  nullable    = false

  validation {
    condition     = contains(["Enabled", "Disabled"], var.profile_status)
    error_message = "Profile status must be either 'Enabled' or 'Disabled'."
  }
}

variable "traffic_routing_method" {
  type        = string
  description = "The traffic routing method for the Traffic Manager profile. Possible values are 'Performance', 'Weighted', 'Priority', 'Geographic', 'MultiValue', and 'Subnet'."
  nullable    = false

  validation {
    condition     = contains(["Performance", "Weighted", "Priority", "Geographic", "MultiValue", "Subnet"], var.traffic_routing_method)
    error_message = "Traffic routing method must be one of: 'Performance', 'Weighted', 'Priority', 'Geographic', 'MultiValue', 'Subnet'."
  }
}

variable "dns_config" {
  type = object({
    relative_name = string
    ttl           = number
  })
  description = <<DESCRIPTION
DNS configuration for the Traffic Manager profile.
- `relative_name` - The relative DNS name provided by this Traffic Manager profile. This value is combined with the DNS domain name used by Azure Traffic Manager to form the FQDN of the profile.
- `ttl` - The DNS Time-To-Live (TTL), in seconds. This informs the local DNS resolvers and DNS clients how long to cache DNS responses provided by this Traffic Manager profile.
DESCRIPTION
  nullable    = false

  validation {
    condition     = var.dns_config.ttl >= 0 && var.dns_config.ttl <= 2147483647
    error_message = "TTL must be between 0 and 2147483647 seconds."
  }
}

variable "monitor_config" {
  type = object({
    protocol                     = string
    port                         = number
    path                         = optional(string, null)
    interval_in_seconds          = optional(number, 30)
    timeout_in_seconds           = optional(number, 10)
    tolerated_number_of_failures = optional(number, 3)
    custom_headers = optional(list(object({
      name  = string
      value = string
    })), null)
    expected_status_code_ranges = optional(list(object({
      min = number
      max = number
    })), null)
  })
  description = <<DESCRIPTION
Monitor configuration for the Traffic Manager profile.
- `protocol` - The protocol used by the monitoring checks. Possible values are 'HTTP', 'HTTPS', and 'TCP'.
- `port` - The port used by the monitoring checks.
- `path` - (Optional) The path used by the monitoring checks. Required when protocol is 'HTTP' or 'HTTPS'.
- `interval_in_seconds` - (Optional) The interval at which health checks are performed. Default is 30 seconds.
- `timeout_in_seconds` - (Optional) The amount of time the Traffic Manager probes wait before considering a health check a failure. Default is 10 seconds.
- `tolerated_number_of_failures` - (Optional) The number of failures that are tolerated before a profile is marked as degraded. Default is 3.
- `custom_headers` - (Optional) List of custom headers to be sent with the health check.
- `expected_status_code_ranges` - (Optional) List of expected HTTP status code ranges.
DESCRIPTION
  nullable    = false

  validation {
    condition     = contains(["HTTP", "HTTPS", "TCP"], var.monitor_config.protocol)
    error_message = "Monitor protocol must be one of: 'HTTP', 'HTTPS', 'TCP'."
  }

  validation {
    condition     = var.monitor_config.port >= 1 && var.monitor_config.port <= 65535
    error_message = "Monitor port must be between 1 and 65535."
  }

  validation {
    condition     = var.monitor_config.interval_in_seconds == null || (var.monitor_config.interval_in_seconds >= 10 && var.monitor_config.interval_in_seconds <= 30)
    error_message = "Monitor interval must be either 10 or 30 seconds."
  }

  validation {
    condition     = var.monitor_config.timeout_in_seconds == null || (var.monitor_config.timeout_in_seconds >= 5 && var.monitor_config.timeout_in_seconds <= 10)
    error_message = "Monitor timeout must be between 5 and 10 seconds."
  }

  validation {
    condition     = var.monitor_config.tolerated_number_of_failures == null || (var.monitor_config.tolerated_number_of_failures >= 0 && var.monitor_config.tolerated_number_of_failures <= 9)
    error_message = "Tolerated number of failures must be between 0 and 9."
  }
}

variable "traffic_view_enrollment_status" {
  type        = string
  default     = "Disabled"
  description = "Indicates whether Traffic View is enabled for the Traffic Manager profile. Possible values are 'Enabled' and 'Disabled'."
  nullable    = false

  validation {
    condition     = contains(["Enabled", "Disabled"], var.traffic_view_enrollment_status)
    error_message = "Traffic View enrollment status must be either 'Enabled' or 'Disabled'."
  }
}

variable "max_return" {
  type        = number
  default     = null
  description = "The maximum number of endpoints to be returned for MultiValue routing type. Only applicable when traffic_routing_method is 'MultiValue'."

  validation {
    condition     = var.max_return == null || (var.max_return >= 1 && var.max_return <= 8)
    error_message = "Max return must be between 1 and 8 when specified."
  }
}

variable "timeouts" {
  type = object({
    create = optional(string, null)
    delete = optional(string, null)
    read   = optional(string, null)
    update = optional(string, null)
  })
  default     = null
  description = "Timeout configuration for the Traffic Manager profile resource operations."
}

# required AVM interfaces
# Traffic Manager does not support customer managed keys

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

# Traffic Manager does not support managed identities or private endpoints

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
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

# tflint-ignore: terraform_unused_declarations
variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}
