variable "name" {
  type        = string
  description = "The name of the Azure endpoint."
}

variable "target_resource_id" {
  type        = string
  description = "The Azure Resource URI of the endpoint."
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

variable "priority" {
  type        = number
  default     = null
  description = "The priority of this endpoint (1-1000) when using the Priority traffic routing method."

  validation {
    condition     = var.priority == null || (var.priority >= 1 && var.priority <= 1000)
    error_message = "Priority must be between 1 and 1000."
  }
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

variable "weight" {
  type        = number
  default     = null
  description = "The weight of this endpoint (1-1000) when using the Weighted traffic routing method."

  validation {
    condition     = var.weight == null || (var.weight >= 1 && var.weight <= 1000)
    error_message = "Weight must be between 1 and 1000."
  }
}
