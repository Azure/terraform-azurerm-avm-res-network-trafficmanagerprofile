variable "name" {
  type        = string
  description = "The name of the external endpoint."
}

variable "target" {
  type        = string
  description = "The fully-qualified DNS name or IP address of the endpoint."
}

variable "traffic_manager_profile_id" {
  type        = string
  description = "The resource ID of the parent Traffic Manager profile."
}

variable "always_serve" {
  type        = string
  default     = "Disabled"
  description = "If Always Serve is enabled, probing for endpoint health will be disabled."

  validation {
    condition     = contains(["Enabled", "Disabled"], var.always_serve)
    error_message = "Always serve must be one of: 'Enabled', 'Disabled'."
  }
}

variable "custom_headers" {
  type = list(object({
    name  = string
    value = string
  }))
  default     = []
  description = "List of custom headers."
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Whether the endpoint is enabled."
}

variable "endpoint_location" {
  type        = string
  default     = null
  description = "Specifies the location of the endpoint when using the Performance traffic routing method."
}

variable "geo_mapping" {
  type        = list(string)
  default     = null
  description = "The list of countries/regions mapped to this endpoint when using the Geographic traffic routing method."
}

variable "ignore_body_changes" {
  type = object({
    network_trafficmanagerprofiles_external_endpoints = optional(list(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Body-relative paths to ignore for each AzAPI resource. Paths use dot notation. Changes take effect only after apply, and ignored configuration is not sent to Azure until the path is removed.

- `network_trafficmanagerprofiles_external_endpoints` - Paths ignored on the external endpoint.
DESCRIPTION
  nullable    = false
}

variable "priority" {
  type        = number
  default     = null
  description = "The priority of this endpoint (1-1000) when using the Priority traffic routing method."

  validation {
    condition     = var.priority == null || (var.priority >= 1 && var.priority <= 1000)
    error_message = "Priority must be between 1 and 1000."
  }
}

variable "resource_types" {
  type = object({
    network_trafficmanagerprofiles_external_endpoints = optional(string, "Microsoft.Network/trafficmanagerprofiles/ExternalEndpoints@2024-04-01-preview")
  })
  default     = {}
  description = <<DESCRIPTION
Map of AzAPI resource type strings used by this submodule. Override any key to target a different API version.

- `network_trafficmanagerprofiles_external_endpoints` - Type for the external endpoint resource.
DESCRIPTION
  nullable    = false
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string))
    interval_seconds     = optional(number)
    max_interval_seconds = optional(number)
  })
  default     = null
  description = <<DESCRIPTION
Retry configuration applied to every supported AzAPI resource declared by this submodule. Defaults to `null` (no custom retry).

- `error_message_regex`  - (Optional) A list of regex patterns matching error messages that trigger a retry.
- `interval_seconds`     - (Optional) Initial interval between retries in seconds.
- `max_interval_seconds` - (Optional) Maximum interval between retries in seconds.

See <https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource#retry> for full semantics.
DESCRIPTION
}

variable "subnets" {
  type = list(object({
    first = string
    last  = optional(string)
    scope = optional(number)
  }))
  default     = []
  description = "The list of subnets, IP addresses, and/or address ranges mapped to this endpoint when using the Subnet traffic routing method."
}

variable "timeouts" {
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
Default per-operation timeouts applied to every supported AzAPI resource declared by this submodule. Defaults to `null` (provider defaults). Each value is a Go duration string (e.g. `30m`, `1h`).

- `create` - (Optional) Timeout for create operations.
- `read`   - (Optional) Timeout for read operations.
- `update` - (Optional) Timeout for update operations.
- `delete` - (Optional) Timeout for delete operations.
DESCRIPTION
}

variable "weight" {
  type        = number
  default     = null
  description = "The weight of this endpoint (1-1000) when using the Weighted traffic routing method."

  validation {
    condition     = var.weight == null || (var.weight >= 1 && var.weight <= 1000)
    error_message = "Weight must be between 1 and 1000."
  }
}
